import 'dart:convert';

import 'package:chips_choice/chips_choice.dart';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:ihl/Getx/controller/SubscriptionHistoryController.dart';
import 'package:ihl/new_design/presentation/pages/home/home_view.dart';
import 'package:ihl/new_design/presentation/pages/home/landingPage.dart';
import 'package:ihl/new_design/presentation/pages/spalshScreen/splashScreen.dart';
import 'package:ihl/views/teleconsultation/viewallneeds.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
import '../../constants/app_texts.dart';
import '../../constants/api.dart';
import '../../constants/routes.dart';
import '../../new_design/presentation/controllers/dashboardControllers/upComingDetailsController.dart';
import '../../utils/app_colors.dart';
import '../../widgets/BasicPageUI.dart';
import '../../widgets/offline_widget.dart';
import '../../widgets/teleconsulation/DashboardTile.dart';
import '../../widgets/teleconsulation/history.dart';
import '../../widgets/teleconsulation/subscriptionTile.dart';
import 'wellness_cart.dart';

class MySubscription extends StatefulWidget {
  final bool afterCall;
  final String courseId;
  final bool onlineCourse;
  final bool cancelEnabled;

  const MySubscription(
      {Key key, this.afterCall, this.courseId, this.onlineCourse, this.cancelEnabled})
      : super(key: key);

  @override
  State<MySubscription> createState() => _MySubscriptionState();
}

class _MySubscriptionState extends State<MySubscription> {
  String finalCourseID,
      iHLUserId,
      ihlConsultantId,
      subscriptionId,
      courseName,
      trainerName,
      provider;
  double _rating = 0.0;

  bool submitting = false, isUpdated = false, isTimer90seconds = false;
  http.Client _client = http.Client(); //3gb
  ValueNotifier<List<String>> selectedDocIdList = ValueNotifier(['Accepted']);

  getCourseID() async {
    if (widget.courseId != null) {
      finalCourseID = widget.courseId.replaceAll("IHLTeleConsultihl_consultant_", "");
      final prefs = await SharedPreferences.getInstance();

      iHLUserId = prefs.getString("userIDFromSubscriptionCall");
      ihlConsultantId = prefs.getString("consultantIDFromSubscriptionCall");
      subscriptionId = prefs.getString("subscriptionIDFromSubscriptionCall");
      courseName = prefs.getString("courseNameFromSubscriptionCall");
      finalCourseID = prefs.getString("courseIDFromSubscriptionCall");
      trainerName = prefs.getString("trainerNameFromSubscriptionCall");
      provider = prefs.getString("providerFromSubscriptionCall");
    }
    if (mounted)
      setState(() {
        isUpdated = true;
      });
  }

  void insertCourseReview(double rating) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var apiToken = prefs.get('auth_token');
    final response = await _client.post(
      Uri.parse(API.iHLUrl + '/consult/insert_course_reviews_new'),
      headers: {
        'Content-Type': 'application/json',
        'ApiToken': '${API.headerr['ApiToken']}',
        'Token': '${API.headerr['Token']}',
      },
      // headers: {'ApiToken': apiToken},
      // "subscription_id": subscriptionId.toString(),
      body: jsonEncode(
        <String, dynamic>{
          "user_ihl_id": iHLUserId.toString(),
          "ihl_consultant_id": ihlConsultantId.toString(),
          "course_name": courseName.toString(),
          "course_id": finalCourseID.toString(),
          "ratings": rating.toInt(),
          "review_text": "",
          "trainer_name": trainerName.toString(),
          "vendor_name": "IHL",
          "provider_name": "$provider"
        },
      ),
    );
    if (response.statusCode == 200) {
      if (mounted)
        setState(() {
          submitting = false;
        });
      Fluttertoast.showToast(
          msg: "Your review is appreciated. Thank you!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.grey,
          textColor: Colors.white,
          fontSize: 16.0);
      Navigator.pop(context);
    } else {
      print(response.body);
      Fluttertoast.showToast(
          msg: "Reviewing failed!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.grey,
          textColor: Colors.white,
          fontSize: 16.0);
      Navigator.pop(context);
    }
  }

  Widget _appointmentLoading(int count) {
    return ListView.builder(
        itemCount: count,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
              direction: ShimmerDirection.ltr,
              period: const Duration(seconds: 2),
              baseColor: Colors.white,
              highlightColor: Colors.grey.withOpacity(0.2),
              child: Container(
                  margin: const EdgeInsets.all(8),
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height / 8,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text('Loading')));
        });
  }

  Widget showReviewDialog() {
    return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
      return SingleChildScrollView(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        SizedBox(
          height: 15.0,
        ),
        // SpinKitFadingCircle(
        //   color: AppColors.primaryColor,
        // ),
        SizedBox(
          height: 5.0,
        ),
        Text(
          "Please Rate Today's Class",
          style: TextStyle(
            color: Color(0xff6D6E71),
            fontSize: 22.0,
          ),
        ),
        SizedBox(
          height: 25.0,
        ),
        Text(
          "Your Ratings",
          style: TextStyle(
            color: AppColors.primaryColor,
            fontSize: 22.0,
          ),
        ),
        SizedBox(
          height: 15.0,
        ),
        SmoothStarRating(
          allowHalfRating: false,
          starCount: 5,
          rating: _rating,
          size: 40.0,
          isReadOnly: false,
          color: Colors.amberAccent,
          borderColor: Colors.grey,
          spacing: 0.0,
          onRated: (value) {
            if (this.mounted) {
              setState(() {
                _rating = value;
              });
            }
          },
        ),
        SizedBox(
          height: 10.0,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: AppColors.primaryColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    side: BorderSide(color: AppColors.primaryColor)),
              ),
              child: Text(
                'Skip',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: submitting == true
                  ? null
                  : () {
                      Navigator.pop(context);
                    },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: AppColors.primaryColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    side: BorderSide(color: AppColors.primaryColor)),
              ),
              child: submitting == true
                  ? SizedBox(
                      height: 20.0,
                      width: 20.0,
                      child: new CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'Submit',
                      style: TextStyle(color: Colors.white),
                    ),
              onPressed: submitting == true
                  ? null
                  : () {
                      if (this.mounted) {
                        setState(() {
                          submitting = true;
                          isTimer90seconds = false;
                        });
                      }
                      insertCourseReview(_rating);
                      Fluttertoast.showToast(
                          msg: "Submitting review!",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.grey,
                          textColor: Colors.white,
                          fontSize: 16.0);
                    },
            ),
          ],
        ),
      ]));
    });
  }

  @override
  void initState() {
    getCourseID();
    Get.put(SubScriptionHistoryController()).onInit();
    super.initState();
    widget.afterCall
        ? WidgetsBinding.instance.addPostFrameCallback((_) async {
            await showDialog<String>(
              context: context,
              builder: (BuildContext context) => new AlertDialog(content: showReviewDialog()),
            );
          })
        : null;
  }

  List<String> appointmentStatus = ['Accepted', 'Cancelled', 'Rejected', 'Requested', 'Completed'];

//Added new variable to get the external URL form the API ⚪⚪
  SubscriptionTile getItem(Map map) {
    return SubscriptionTile(
      external_url: map["external_url"],
      subscription_id: map["subscription_id"],
      isCompleted: map['completed'] ?? false,
      course_fees: map["course_fees"].toString(),
      trainerId: map["consultant_id"],
      trainerName: map["consultant_name"],
      title: map["title"],
      duration: map["course_duration"],
      time: map["course_time"],
      provider: map['provider'],
      isApproved: map['approval_status'] == "Accepted" || map['approval_status'] == "Approved",
      isRejected: map['approval_status'] == "Rejected",
      isRequested: map['approval_status'] == "Requested" || map['approval_status'] == 'requested',
      isCancelled: map['approval_status'] == "Cancelled" || map['approval_status'] == 'cancelled',
      courseOn: map['course_on'],
      courseTime: map['course_time'],
      courseId: map['course_id'],
      courseType: map['course_type'].toString().toLowerCase().contains('days') ||
              map['course_type'].toString().toLowerCase().contains('daily')
          ? 'daily'
          : map['course_type'],
    );
  }

  @override
  Widget build(BuildContext context) {
    final _controller = Get.put(SubScriptionHistoryController());
    return ConnectivityWidgetWrapper(
      disableInteraction: true,
      offlineWidget: OfflineWidget(),
      child: WillPopScope(
        // ignore: missing_return
        onWillPop: () {
          Get.delete<SubScriptionHistoryController>();

          // ViewallTeleDashboard();
          bool backNavv2 = localSotrage.read("subNav") ?? false;
          if (widget.afterCall || backNavv2) {
            Get.put(UpcomingDetailsController()).onInit();
            Get.offAll(LandingPage());
          } else if (widget.cancelEnabled == true) {
            Get.put(UpcomingDetailsController()).onInit();
            Get.offAll(LandingPage());
          } else {
            Get.put(UpcomingDetailsController()).onInit();
            Get.back();
          }

          // if (backNavv2) {
          //   Get.off(Home());
          //   localSotrage.write("subNav", false);
          // } else {
          //   if (backNavv ?? false) {
          //     Navigator.pop(context);
          //     localSotrage.write("healthEmarketNavigation", false);
          //   } else {
          //     widget.afterCall?
          //     Get.off(WellnessCart()):Get.back();
          //   }
          // }
        },
        child: BasicPageUI(
          appBar: Column(
            children: [
              SizedBox(
                width: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // BackButton(
                  //   onPressed: () => Navigator.of(context)
                  //       .pushReplacementNamed(Routes.WellnessCart),
                  //   color: Colors.white,
                  // ),
                  widget.onlineCourse ?? false
                      ? IconButton(
                          icon: Icon(Icons.arrow_back_ios),
                          onPressed: () {
                            bool backNavv = localSotrage.read("healthEmarketNavigation");
                            bool backNavv2 = localSotrage.read("subNav") ?? false;
                            if (widget.afterCall) {
                              Get.put(UpcomingDetailsController()).onInit();
                              Get.offAll(LandingPage());
                            } else if (widget.cancelEnabled == true) {
                              Get.put(UpcomingDetailsController()).onInit();
                              Get.offAll(LandingPage());
                            } else {
                              Get.put(UpcomingDetailsController()).onInit();
                              Get.back();
                            }
                            // if (backNavv2) {
                            //   Get.off(Home());
                            //   localSotrage.write("subNav", false);
                            // } else {
                            //   if (backNavv ?? true) {
                            //     Navigator.pop(context);
                            //     localSotrage.write("healthEmarketNavigation", false);
                            //   } else {
                            //     widget.afterCall?
                            //     Get.off(WellnessCart()):Get.back();
                            //   }
                            // }
                          }, //replaces the screen to Main dashboard
                          color: Colors.white,
                        )
                      : IconButton(
                          icon: Icon(Icons.arrow_back_ios),
                          onPressed: () {
                            bool backNavv = localSotrage.read("healthEmarketNavigation");
                            bool backNavv2 = localSotrage.read("subNav") ?? false;
                            if (widget.afterCall || backNavv2) {
                              Get.put(UpcomingDetailsController()).onInit();
                              Get.offAll(LandingPage());
                            } else if (widget.cancelEnabled == true) {
                              Get.put(UpcomingDetailsController()).onInit();
                              Get.offAll(LandingPage());
                            } else if (!widget.afterCall) {
                              Get.put(UpcomingDetailsController()).onInit();
                              Get.offAll(LandingPage());
                            } else {
                              Get.put(UpcomingDetailsController()).onInit();
                              Get.back();
                            }
                          }, //replaces the screen to Main dashboard
                          color: Colors.white,
                        ),
                  Text(
                    AppTexts.mySubscriptions,
                    style: TextStyle(color: Colors.white, fontSize: 25),
                  ),

                  SizedBox(
                    width: 40,
                  )
                ],
              ),
              SizedBox(
                height: 40,
              )
            ],
          ),
          body: Column(
            children: [
              GetBuilder<SubScriptionHistoryController>(
                id: 'subscriptionLoading',
                builder: (_) => _.isLoading
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DashboardTile(
                          icon: FontAwesomeIcons.history,
                          text: 'Loading ' + '...',
                          color: AppColors.history,
                          trailing: CircularProgressIndicator(),
                          onTap: () {},
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.all(
                            Radius.circular(20),
                          ),
                          child: Column(
                            children: [
                              ValueListenableBuilder(
                                  valueListenable: selectedDocIdList,
                                  builder: (cxt, val, __) {
                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Content(
                                        title: 'Filter Subscription',
                                        child: FormField<List<String>>(
                                          initialValue: [],
                                          builder: (state) {
                                            return Column(
                                              children: <Widget>[
                                                Container(
                                                  alignment: Alignment.centerLeft,
                                                  child: ChipsChoice<String>.multiple(
                                                    // value: state.value,
                                                    value: val,
                                                    choiceItems: C2Choice.listFrom<String, String>(
                                                      source: appointmentStatus,
                                                      value: (i, v) => v,
                                                      label: (i, v) => v,
                                                    ),
                                                    onChanged: (val) {
                                                      if (val.length > 1) {
                                                        val.removeAt(0);
                                                      }
                                                      print(val);
                                                      selectedDocIdList.value = val;
                                                      if (val.contains('Accepted')) {
                                                        _.filterType = "Accepted";
                                                        _.selectedList = [];
                                                        _.updateList(completed: false);
                                                      } else if (val.contains('Cancelled')) {
                                                        _.filterType = "Cancelled";
                                                        _.selectedList = [];
                                                        _.updateList(completed: false);
                                                      } else if (val.contains('Rejected')) {
                                                        _.filterType = "Rejected";
                                                        _.selectedList = [];
                                                        _.updateList(completed: false);
                                                      } else if (val.contains('Requested')) {
                                                        _.filterType = "requested";
                                                        _.selectedList = [];
                                                        _.updateList(completed: false);
                                                      } else if (val.contains('Completed')) {
                                                        _.filterType = "Accepted";
                                                        _.selectedList = [];
                                                        _.updateList(completed: true);
                                                      }
                                                      selectedDocIdList.notifyListeners();
                                                    },
                                                    choiceStyle: C2ChoiceStyle(
                                                      borderRadius: BorderRadius.circular(8.0),
                                                      color: Colors
                                                          .grey, // Set the color for inactive chips
                                                      brightness: Brightness.light,
                                                    ),
                                                    choiceActiveStyle: C2ChoiceStyle(
                                                      borderRadius: BorderRadius.circular(8.0),
                                                      color: Colors
                                                          .blue, // Set the color for active chips
                                                      brightness: Brightness.light,
                                                    ),
                                                    wrapped: true,
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        ),
                                      ),
                                    );
                                  }),
                              SizedBox(
                                height: MediaQuery.of(context).size.height / 1.7,
                                child: GetBuilder<SubScriptionHistoryController>(
                                    id: 'listupdated',
                                    builder: (_) {
                                      return _.switchLoading
                                          ? _appointmentLoading(6)
                                          : _.selectedList.length == 0
                                              ? Center(child: Text('No Subscriptions found'))
                                              : ListView.builder(
                                                  controller: _.controller,
                                                  itemCount: _.selectedList.length,
                                                  itemBuilder: (ctx, index) =>
                                                      getItem(_.selectedList[index]),
                                                );
                                    }),
                              )
                            ],
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
