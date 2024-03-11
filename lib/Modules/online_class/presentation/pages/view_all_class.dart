import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import '../../../../new_design/module/online_serivices/functionalities/online_services_dashboard_functionalities.dart';
import '../../../../new_design/presentation/controllers/dashboardControllers/dashBoardContollers.dart';
import '../../functionalities/upcoming_courses.dart';
import '../../bloc/trainer_status/bloc/trainer_bloc.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../new_design/data/providers/network/apis/classImageApi/classImageApi.dart';
import '../../../../new_design/module/online_serivices/bloc/online_services_api_bloc.dart';
import '../../../../new_design/module/online_serivices/bloc/online_services_api_event.dart';
import '../../../../new_design/module/online_serivices/bloc/search_animation_bloc/courseDetailBloc/courseDetailBloc.dart';
import '../../../../new_design/module/online_serivices/bloc/search_animation_bloc/search_animation_bloc.dart';
import '../../../../new_design/module/online_serivices/data/model/get_subscribtion_list.dart';
import '../../../../new_design/module/online_serivices/data/repositories/online_services_api.dart';
import '../../../../new_design/module/online_serivices/onilne_services_main.dart';
import '../../../../new_design/module/online_serivices/presentation/online_class_screens/book_class_after_subscription.dart';
import '../../../../new_design/presentation/Widgets/bloc_widgets/consultant_status/consultantstatus_bloc.dart';
import '../../../../new_design/presentation/clippath/subscriptionTagClipPath.dart';
import '../../../../new_design/presentation/pages/dashboard/common_screen_for_navigation.dart';
import '../../../../utils/app_colors.dart';
import '../../data/model/getClassSpecialityNameList.dart';
import '../../bloc/online_class_api_bloc.dart';
import '../../bloc/online_class_events.dart';
import '../../bloc/online_class_state.dart';
import '../../functionalities/cancel_subscription.dart';
import '../../functionalities/class_time_calculation.dart';
import '../widgets/join_call_widget.dart';
import '../widgets/online_service_widgets.dart';

class ViweAllClass extends StatelessWidget {
  List<Subscription> subcriptionList;
  bool subscribed;
  String isHome;
  ViweAllClass({Key key, this.subcriptionList, this.subscribed, this.isHome}) : super(key: key);
  List<String> classStatus = <String>[
    'Accepted',
    'Cancelled',
    'Rejected',
    'Requested',
    "Completed"
  ];
  final OnlineServicesApiCall _onlineServicesApi = OnlineServicesApiCall();
  ValueNotifier<bool> isloading = ValueNotifier<bool>(false);
  ValueNotifier<bool> isReasonFiled = ValueNotifier<bool>(false);
  final TabBarController _tabController = Get.find<TabBarController>();
  @override
  Widget build(BuildContext context) {
    String textValue = '';
    return WillPopScope(
      onWillPop: isHome == "Yes"
          ? () {
              _tabController.updateSelectedIconValue(value: "Home");
              Get.back();
              return null;
            }
          : () {
              return Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => MultiBlocProvider(providers: [
                            BlocProvider(
                              create: (BuildContext context) => SubscrptionFilterBloc()
                                ..add(
                                    FilterSubscriptionEvent(filterType: "Accepted", endIndex: 30)),
                            ),
                            BlocProvider(create: (BuildContext context) => SearchAnimationBloc()),
                            BlocProvider(create: (BuildContext context) => ConsultantstatusBloc()),
                            BlocProvider(create: (BuildContext context) => TrainerBloc()),
                            BlocProvider(
                                create: (BuildContext context) => OnlineServicesApiBloc()
                                  ..add(OnlineServicesApiEvent(data: "specialty"))),
                            BlocProvider(
                                create: (BuildContext context) => StreamOnlineServicesApiBloc()
                                  ..add(StreamOnlineServicesApiEvent(data: "subscriptionDetails"))),
                            BlocProvider(
                                create: (BuildContext context) => StreamOnlineClassApiBloc()
                                  ..add(StreamOnlineClassApiEvent(data: "subscriptionDetails")))
                          ], child: const OnlineServicesDashboard())));
            },
      child: CommonScreenForNavigation(
          appBar: AppBar(
            backgroundColor: AppColors.primaryColor,
            elevation: 0,
            centerTitle: true,
            title: const Text("My Subscriptions", style: TextStyle(color: Colors.white)),
            leading: InkWell(
              onTap: () {
                // if (subscribed != null) {
                //   Navigator.push(
                //       context,
                //       MaterialPageRoute(
                //           builder: (BuildContext context) => MultiBlocProvider(providers: [
                //                 BlocProvider(
                //                   create: (BuildContext context) => SubscrptionFilterBloc()
                //                     ..add(FilterSubscriptionEvent(
                //                         filterType: "Accepted", endIndex: 30)),
                //                 ),
                //                 BlocProvider(
                //                     create: (BuildContext context) => SearchAnimationBloc()),
                //                 BlocProvider(
                //                     create: (BuildContext context) => ConsultantstatusBloc()),
                //                 BlocProvider(create: (BuildContext context) => TrainerBloc()),
                //                 BlocProvider(
                //                     create: (BuildContext context) => OnlineServicesApiBloc()
                //                       ..add(OnlineServicesApiEvent(data: "specialty"))),
                //                 BlocProvider(
                //                     create: (BuildContext context) => StreamOnlineServicesApiBloc()
                //                       ..add(StreamOnlineServicesApiEvent(
                //                           data: "subscriptionDetails"))),
                //                 BlocProvider(
                //                     create: (BuildContext context) => StreamOnlineClassApiBloc()
                //                       ..add(StreamOnlineClassApiEvent(data: "subscriptionDetails")))
                //               ], child: const OnlineServicesDashboard())));
                // } else {
                //   Get.back();
                // }
                isHome == "Yes"
                    ? {_tabController.updateSelectedIconValue(value: "Home"), Get.back()}
                    : Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) => MultiBlocProvider(providers: [
                                  BlocProvider(
                                    create: (BuildContext context) => SubscrptionFilterBloc()
                                      ..add(FilterSubscriptionEvent(
                                          filterType: "Accepted", endIndex: 30)),
                                  ),
                                  BlocProvider(
                                      create: (BuildContext context) => SearchAnimationBloc()),
                                  BlocProvider(
                                      create: (BuildContext context) => ConsultantstatusBloc()),
                                  BlocProvider(create: (BuildContext context) => TrainerBloc()),
                                  BlocProvider(
                                      create: (BuildContext context) => OnlineServicesApiBloc()
                                        ..add(OnlineServicesApiEvent(data: "specialty"))),
                                  BlocProvider(
                                      create: (BuildContext context) =>
                                          StreamOnlineServicesApiBloc()
                                            ..add(StreamOnlineServicesApiEvent(
                                                data: "subscriptionDetails"))),
                                  BlocProvider(
                                      create: (BuildContext context) => StreamOnlineClassApiBloc()
                                        ..add(
                                            StreamOnlineClassApiEvent(data: "subscriptionDetails")))
                                ], child: const OnlineServicesDashboard())));
              },
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
              ),
            ),
          ),
          content: MultiBlocProvider(
            providers: [
              BlocProvider(create: (BuildContext context) => TrainerBloc()),
              BlocProvider(
                create: (BuildContext context) => SubscrptionFilterBloc()
                  ..add(FilterSubscriptionEvent(filterType: "Accepted", endIndex: 5)),
              )
            ],
            child: BlocBuilder<SubscrptionFilterBloc, SubscriptionFilterState>(
              builder: (BuildContext context, SubscriptionFilterState state) {
                final SubscrptionFilterBloc subSrciptionFilterBloc =
                    BlocProvider.of<SubscrptionFilterBloc>(context);
                return state is FilterLoadedState
                    ? Column(
                        children: <Widget>[
                          _buildStatusRow(state.filterType, subSrciptionFilterBloc),
                          _buildSubscriptionList(state, subSrciptionFilterBloc, context)
                        ],
                      )
                    : Column(
                        children: <Widget>[
                          _buildStatusRow("", subSrciptionFilterBloc),
                          for (int i = 0; i < 4; i++)
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Shimmer.fromColors(
                                direction: ShimmerDirection.ltr,
                                enabled: true,
                                baseColor: Colors.white,
                                highlightColor: Colors.grey.shade300,
                                child: Container(
                                  height: 16.h,
                                  width: 92.w,
                                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
              },
            ),
          )),
    );
  }

  Widget _buildStatusRow(String selectedFilter, var filterBloc) {
    ScrollController _scrollController = ScrollController();
    return ScrollbarTheme(
      data: ScrollbarThemeData(
        thumbColor: MaterialStateProperty.all(AppColors.primaryAccentColor.withOpacity(0.4)),
        interactive: true,
        radius: const Radius.circular(10.0),
        thickness: MaterialStateProperty.all(1),
        minThumbLength: 20,
      ),
      child: Scrollbar(
        controller: _scrollController,
        thickness: 1.5,
        thumbVisibility: true,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          controller: _scrollController,
          child: Row(
            children: classStatus.map((String e) {
              return InkWell(
                  onTap: () {
                    filterBloc.add(FilterSubscriptionEvent(filterType: e, endIndex: 15));
                  },
                  child: OnlineClassWidgets.classStatusBar(title: e, selectedTile: selectedFilter));
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildSubscriptionList(
      FilterLoadedState state, var subSrciptionFilterBloc, BuildContext context) {
    contextForJoincall = context;
    OnlineServicesFunctions onlineServicesFunctions = OnlineServicesFunctions();
    bool hasSplChar({String text}) {
      bool value = false;
      for (int e in text.runes) {
        print(e.toString());
        if (58 > e || e > 64) {
          value = false;
        } else {
          value = true;
          break;
        }
      }
      return value;
    }

    showDia({var e}) {
      TextEditingController textEditingController = TextEditingController();
      final GlobalKey<FormState> formKey = GlobalKey<FormState>();
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: const Text(
                'Please provide the reason for Cancellation!',
                style: TextStyle(color: Color(0xff4393cf)),
                textAlign: TextAlign.center,
              ),
              content: Form(
                key: formKey,
                child: TextFormField(
                  controller: textEditingController,
                  validator: (String value) {
                    if (!(value.isNotEmpty && value.length >= 5 && value.trim().length >= 5)) {
                      return "Reason should contain atleast 5 characters";
                    } else if (hasSplChar(text: value)) {
                      return "Reason shouldn't contain special characters";
                    }
                    return null;
                  },
                  onChanged: (String value) {
                    if (formKey.currentState.validate()) {
                      isReasonFiled.value = true;
                    } else {
                      isReasonFiled.value = false;
                    }
                    // textValue = value;
                    // if (textValue != "" && textValue.isNotEmpty && textValue != " ") {
                    // } else {}
                  },
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 18),
                    labelText: "Specify your reason",
                    fillColor: Colors.white24,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        borderSide: const BorderSide(color: Colors.blueGrey)),
                  ),
                  maxLines: 1,
                ),
              ),
              actions: <Widget>[
                ValueListenableBuilder<bool>(
                    valueListenable: isloading,
                    builder: (_, bool c, __) {
                      return c == false
                          ? Row(
                              mainAxisAlignment: isloading.value
                                  ? MainAxisAlignment.center
                                  : MainAxisAlignment.spaceAround,
                              children: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    // ignore: deprecated_member_use
                                    primary: AppColors.primaryColor,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10.0),
                                        side: BorderSide(
                                            color: isloading.value
                                                ? Colors.grey
                                                : AppColors.primaryColor)),
                                  ),
                                  onPressed: () {
                                    isReasonFiled.value = false;
                                    Navigator.of(context).pop(); // Close the dialog
                                  },
                                  child: Text(
                                    'Go Back',
                                    style: TextStyle(
                                        color: isloading.value ? Colors.blue : Colors.white),
                                  ),
                                ),
                                ValueListenableBuilder<bool>(
                                    valueListenable: isReasonFiled,
                                    builder: (_, bool field, __) {
                                      return ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10.0),
                                              side:
                                                  const BorderSide(color: AppColors.primaryColor)),
                                          backgroundColor:
                                              field ? AppColors.primaryColor : Colors.grey,
                                        ),
                                        onPressed: field
                                            ? () async {
                                                isReasonFiled.value = false;
                                                isloading.value = true;
                                                dynamic msg = await CancelSubscription()
                                                    .cancelSubscription(
                                                        e.subscriptionId,
                                                        "user",
                                                        textEditingController.text,
                                                        e.provider.toString());
                                                try {
                                                  await _onlineServicesApi.updateUserDetails();
                                                  subSrciptionFilterBloc.add(
                                                      FilterSubscriptionEvent(
                                                          filterType: "Accepted", endIndex: 10));
                                                } catch (e) {
                                                  isloading.value = false;
                                                  print(e);
                                                }
                                                Navigator.of(context).pop();
                                                isloading.value = false;
                                              }
                                            : null,
                                        child: const Text('Submit'),
                                      );
                                    }),
                              ],
                            )
                          : Center(
                              child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10.0),
                                        side: const BorderSide(color: AppColors.primaryColor)),
                                    backgroundColor: Colors.grey,
                                  ),
                                  onPressed: null,
                                  child: Shimmer.fromColors(
                                    direction: ShimmerDirection.ltr,
                                    period: const Duration(seconds: 2),
                                    baseColor: Colors.white,
                                    highlightColor: Colors.grey,
                                    child: Text(
                                      'Updating Subscription',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: Colors.blueAccent,
                                      ),
                                    ),
                                  )),
                            );
                    }),
              ]);
        },
      );
    }

    return state is FilterLoadedState && state.subscriptionList.isEmpty
        ? Padding(
            padding: EdgeInsets.only(left: 15.w, top: 20.h),
            child: Center(
              child: SizedBox(
                height: 10.h,
                width: 80.w,
                child: Text(
                  "No Subscriptions Found!",
                  style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          )
        : Container(
            height: 72.h,
            color: Colors.transparent,
            child: SingleChildScrollView(
              child: Column(
                children: (state is FilterLoadedState ? state.subscriptionList : []).map((var e) {
                  UpcomingCourses().trainerStatusFromFirebase(context.read, e.consultantId);
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        InkWell(
                          onTap: state is FilterLoadedState
                              ? state.filterType == "Accepted" || state.filterType == "Requested"
                                  ? () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (BuildContext context) => MultiBlocProvider(
                                                    providers: [
                                                      BlocProvider(
                                                        create: (BuildContext context) =>
                                                            CourseDetailBloc()
                                                              ..add(CourseEventTrigger(
                                                                  courseID: e.courseId)),
                                                      ),
                                                    ],
                                                    child: BookClassAfterSubscription(
                                                      joinCallWidget: joinCallwidget(
                                                        subcriptionList: e,
                                                        ui: const Text('data'),
                                                        noTime: true,
                                                      ),
                                                      classDetail: e,
                                                    ),
                                                  )));
                                    }
                                  : () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (BuildContext context) => MultiBlocProvider(
                                                    providers: [
                                                      BlocProvider(
                                                        create: (BuildContext context) =>
                                                            CourseDetailBloc()
                                                              ..add(CourseEventTrigger(
                                                                  courseID: e.courseId)),
                                                      ),
                                                    ],
                                                    child: BookClassAfterSubscription(
                                                      classDetail: e,
                                                      joinCallWidget: joinCallwidget(
                                                        subcriptionList: e,
                                                        ui: const Text('data'),
                                                        noTime: true,
                                                      ),
                                                    ),
                                                  )));
                                    }
                              : () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (BuildContext context) => MultiBlocProvider(
                                                providers: [
                                                  BlocProvider(
                                                    create: (BuildContext context) =>
                                                        CourseDetailBloc()
                                                          ..add(CourseEventTrigger(
                                                              courseID: e.courseId)),
                                                  ),
                                                ],
                                                child: BookClassAfterSubscription(
                                                  classDetail: e,
                                                  joinCallWidget: joinCallwidget(
                                                    subcriptionList: e,
                                                    ui: const Text('data'),
                                                    noTime: true,
                                                  ),
                                                ),
                                              )));
                                },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(2),
                              boxShadow: [
                                BoxShadow(
                                  offset: const Offset(1, 1),
                                  spreadRadius: 4,
                                  blurRadius: 5,
                                  color: Colors.grey.shade300,
                                )
                              ],
                            ),
                            child: FutureBuilder(
                              future: ClassImage().getCourseImageURL([e.courseId]),
                              builder: (BuildContext ctx, AsyncSnapshot snapshot) {
                                if (snapshot.hasData) {
                                  List<String> image = snapshot.data[0]['base_64'].split(',');
                                  Uint8List bytes1;
                                  bytes1 = const Base64Decoder().convert(image[1].toString());
                                  return bytes1 == null
                                      ? const Placeholder()
                                      : Padding(
                                          padding:
                                              const EdgeInsets.only(top: 15, left: 15, right: 15.0),
                                          child: Column(
                                            children: [
                                              Container(
                                                height: 15.h,
                                                decoration: BoxDecoration(
                                                  color: const Color(0xff7c94b6),
                                                  borderRadius:
                                                      const BorderRadius.all(Radius.circular(4.0)),
                                                  image: DecorationImage(
                                                      image: Image.memory(
                                                        base64Decode(image[1].toString()),
                                                      ).image,
                                                      fit: BoxFit.cover),
                                                ),
                                              ),
                                              Container(
                                                // height: 10.h,
                                                color: Colors.white,
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets.symmetric(
                                                          vertical: 6.0, horizontal: 3.0),
                                                      child: Text(e.title ?? " ",
                                                          style: const TextStyle(
                                                              color: FitnessAppTheme.darkText)),
                                                    ),
                                                    state.filterType == "Accepted" ||
                                                            state.filterType == "Requested"
                                                        ? Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Text(
                                                                  TimeCalculation()
                                                                      .getClassStartTime(
                                                                          e.courseTime),
                                                                  style: const TextStyle(
                                                                      color: FitnessAppTheme
                                                                          .darkText)),
                                                              state.filterType == "Accepted" ||
                                                                      state.filterType ==
                                                                          "Requested"
                                                                  ? Row(
                                                                      children: [
                                                                        GestureDetector(
                                                                            onTap: () {
                                                                              showDia(e: e);
                                                                            },
                                                                            child: const Text(
                                                                                'Cancel')),
                                                                        SizedBox(
                                                                          width: 3.w,
                                                                        ),
                                                                        Container(
                                                                          padding:
                                                                              const EdgeInsets.all(
                                                                                  8),
                                                                          child: joinCallwidget(
                                                                            subcriptionList: e,
                                                                            ui: const Text('data'),
                                                                            noTime: true,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    )
                                                                  : SizedBox(
                                                                      height: 5.h,
                                                                    ),
                                                            ],
                                                          )
                                                        : Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment.spaceEvenly,
                                                            children: [
                                                              Text(
                                                                  onlineServicesFunctions
                                                                      .parseDateToText(
                                                                          e.courseDuration),
                                                                  style: const TextStyle(
                                                                      color: FitnessAppTheme
                                                                          .nearlyBlue)),
                                                              // const Spacer(),
                                                              Text(
                                                                  TimeCalculation()
                                                                      .getClassStartTime(
                                                                          e.courseTime),
                                                                  style: const TextStyle(
                                                                      color: FitnessAppTheme
                                                                          .darkText)),
                                                              // const Spacer(),
                                                              SizedBox(
                                                                height: 5.h,
                                                              ),
                                                            ],
                                                          )
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
                                    e.courseTime ?? " ",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Poppins',
                                      fontSize: 15.sp,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          );
  }
}

class ViewEachCategory extends StatelessWidget {
  List<SpecialityTypeList> viewClassCategoryList;

  ViewEachCategory({Key key, this.viewClassCategoryList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String textValue = '';
    return CommonScreenForNavigation(
        appBar: AppBar(
          backgroundColor: AppColors.primaryColor,
          elevation: 0,
          centerTitle: true,
          title: const Text("My Subscriptions", style: TextStyle(color: Colors.white)),
          leading: InkWell(
            onTap: () {
              Get.back();
            },
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
            ),
          ),
        ),
        content: SizedBox(
          width: 100.w,
          height: 100.h,
          child: SingleChildScrollView(
            child: Column(children: <Widget>[
              Column(
                children: <Widget>[
                  SizedBox(
                    height: 90.h,
                    child: ListView.builder(
                      itemCount: viewClassCategoryList.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              InkWell(
                                onTap: () {
                                  // Navigator.push(
                                  //     context,
                                  //     MaterialPageRoute(
                                  //         builder: (BuildContext context) =>
                                  //             ClassDetailAfterBook(
                                  //               classDetail: viewClassCategoryList,
                                  //             )));
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(2),
                                      boxShadow: [
                                        BoxShadow(
                                            offset: const Offset(1, 1),
                                            spreadRadius: 4,
                                            blurRadius: 5,
                                            color: Colors.grey.shade300)
                                      ]),
                                  child: FutureBuilder(
                                    future: ClassImage()
                                        .getCourseImageURL([viewClassCategoryList[index].courseId]),
                                    builder: (BuildContext ctx, AsyncSnapshot snapshot) {
                                      if (snapshot.hasData) {
                                        List<String> image = snapshot.data[0]['base_64'].split(',');
                                        Uint8List bytes1;
                                        bytes1 = const Base64Decoder().convert(image[1].toString());
                                        return bytes1 == null
                                            ? const Placeholder()
                                            : Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 15, left: 15, right: 15.0),
                                                child: Column(
                                                  children: [
                                                    SizedBox(
                                                      height: 15.h,
                                                      child: Image.network(
                                                        viewClassCategoryList[index]
                                                            .courseImgUrl
                                                            .toString(),
                                                      ),
                                                    ),
                                                    Container(
                                                      height: 10.h,
                                                      color: Colors.white,
                                                      child: Padding(
                                                        padding: const EdgeInsets.only(
                                                            top: 4.0, left: 4.0, right: 4.0),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment.start,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Text(
                                                                viewClassCategoryList[index].title),
                                                            // Row(
                                                            //   mainAxisAlignment:
                                                            //       MainAxisAlignment.spaceBetween,
                                                            //   children: [
                                                            //     Text(TimeCalculation()
                                                            //         .getClassStartTime(
                                                            //             viewClassCategoryList[index]
                                                            //                 .courseTime)),
                                                            //     Row(
                                                            //       children: [
                                                            //         GestureDetector(
                                                            //             onTap: () {
                                                            //               showDialog(
                                                            //                 context: context,
                                                            //                 builder: (BuildContext
                                                            //                     context) {
                                                            //                   return AlertDialog(
                                                            //                     title: const Text(
                                                            //                       'Please provide the reason for Cancellation!',
                                                            //                       style: TextStyle(
                                                            //                           color: Color(
                                                            //                               0xff4393cf)),
                                                            //                       textAlign:
                                                            //                           TextAlign
                                                            //                               .center,
                                                            //                     ),
                                                            //                     content: TextField(
                                                            //                       onChanged: (String
                                                            //                           value) {
                                                            //                         textValue =
                                                            //                             value;
                                                            //                       },
                                                            //                       decoration:
                                                            //                           InputDecoration(
                                                            //                         contentPadding:
                                                            //                             const EdgeInsets
                                                            //                                     .symmetric(
                                                            //                                 vertical:
                                                            //                                     15,
                                                            //                                 horizontal:
                                                            //                                     18),
                                                            //                         labelText:
                                                            //                             "Specify your reason",
                                                            //                         fillColor: Colors
                                                            //                             .white24,
                                                            //                         border: OutlineInputBorder(
                                                            //                             borderRadius:
                                                            //                                 BorderRadius.circular(
                                                            //                                     15.0),
                                                            //                             borderSide:
                                                            //                                 const BorderSide(
                                                            //                                     color:
                                                            //                                         Colors.blueGrey)),
                                                            //                       ),
                                                            //                       maxLines: 1,
                                                            //                     ),
                                                            //                     actions: <Widget>[
                                                            //                       Row(
                                                            //                         mainAxisAlignment:
                                                            //                             MainAxisAlignment
                                                            //                                 .spaceAround,
                                                            //                         children: [
                                                            //                           ElevatedButton(
                                                            //                             style: ElevatedButton
                                                            //                                 .styleFrom(
                                                            //                               // ignore: deprecated_member_use
                                                            //                               primary:
                                                            //                                   AppColors
                                                            //                                       .primaryColor,
                                                            //                               shape: RoundedRectangleBorder(
                                                            //                                   borderRadius: BorderRadius.circular(
                                                            //                                       10.0),
                                                            //                                   side:
                                                            //                                       const BorderSide(color: AppColors.primaryColor)),
                                                            //                             ),
                                                            //                             onPressed:
                                                            //                                 () {
                                                            //                               Navigator.of(
                                                            //                                       context)
                                                            //                                   .pop(); // Close the dialog
                                                            //                             },
                                                            //                             child: const Text(
                                                            //                                 'Go Back'),
                                                            //                           ),
                                                            //                           ElevatedButton(
                                                            //                             style: ElevatedButton
                                                            //                                 .styleFrom(
                                                            //                               shape: RoundedRectangleBorder(
                                                            //                                   borderRadius: BorderRadius.circular(
                                                            //                                       10.0),
                                                            //                                   side:
                                                            //                                       const BorderSide(color: AppColors.primaryColor)),
                                                            //                               backgroundColor:
                                                            //                                   AppColors
                                                            //                                       .primaryColor,
                                                            //                             ),
                                                            //                             onPressed:
                                                            //                                 () async {
                                                            //                               // await CancelSubscription().cancelSubscription(
                                                            //                               //     viewClassCategoryList[index]
                                                            //                               //         .subscriptionId,
                                                            //                               //     "user",
                                                            //                               //     textValue);
                                                            //                               // Navigator.of(
                                                            //                               //         context)
                                                            //                               //     .pop();
                                                            //                             },
                                                            //                             child: const Text(
                                                            //                                 'Submit'),
                                                            //                           ),
                                                            //                         ],
                                                            //                       ),
                                                            //                     ],
                                                            //                   );
                                                            //                 },
                                                            //               );
                                                            //             },
                                                            //             child:
                                                            //                 const Text('Cancel')),
                                                            //         Row(
                                                            //           children: [
                                                            //             TextButton(
                                                            //                 onPressed: () {},
                                                            //                 child:
                                                            //                     const Text("Join")),
                                                            //             Icon(
                                                            //                 Icons
                                                            //                     .arrow_forward_ios_sharp,
                                                            //                 size: 15.sp)
                                                            //           ],
                                                            //         ),
                                                            //       ],
                                                            //     )
                                                            //   ],
                                                            // )
                                                          ],
                                                        ),
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
                              // SizedBox(
                              //   child: ClipPath(
                              //     clipper: SubscriptionClipPath(),
                              //     child: Container(
                              //       color: AppColors.primaryAccentColor,
                              //       child: FittedBox(
                              //         fit: BoxFit.fill,
                              //         child: Padding(
                              //           padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                              //           child: Text(
                              //             viewClassCategoryList[index].,
                              //             style: TextStyle(
                              //                 color: Colors.white,
                              //                 fontFamily: 'Poppins',
                              //                 fontSize: 15.sp),
                              //           ),
                              //         ),
                              //       ),
                              //     ),
                              //   ),
                              // ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 11.h)
                ],
              ),
            ]),
          ),
        ));
  }
}
