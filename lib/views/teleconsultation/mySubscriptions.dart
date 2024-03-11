import 'dart:convert';

import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:ihl/constants/api.dart';
import 'package:ihl/constants/app_texts.dart';
import 'package:ihl/constants/routes.dart';
import 'package:ihl/constants/spKeys.dart';
import 'package:ihl/utils/CrossbarUtil.dart';
import 'package:ihl/utils/CrossbarUtil.dart' as s;
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/views/teleconsultation/active_subscriptions.dart';
import 'package:ihl/views/teleconsultation/past_expired_subscriptions.dart';
import 'package:ihl/views/teleconsultation/wellness_cart.dart';
import 'package:ihl/widgets/BasicPageUI.dart';
import 'package:ihl/widgets/offline_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

class MySubscriptions extends StatefulWidget {
  final bool afterCall;
  final String courseId;
  final bool onlineCourse;

  const MySubscriptions({Key key, this.afterCall, this.courseId, this.onlineCourse})
      : super(key: key);

  @override
  _MySubscriptionsState createState() => _MySubscriptionsState();
}

class _MySubscriptionsState extends State<MySubscriptions> {
  http.Client _client = http.Client(); //3gb
  bool submitting = false;
  double _rating = 0.0;
  final reviewTextController = TextEditingController();
  String finalCourseID;
  String iHLUserId;
  bool hasSubscription = false;
  List subscriptions = [];
  List approvedSubscriptions;
  bool reviewDone = false;

  String ihlConsultantId;
  String subscriptionId;
  String courseName;
  String vendorName;
  String trainerName;
  String provider;
  bool isUpdated = false;

  @override
  void initState() {
    getCourseID();
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
  Widget build(BuildContext context) {
    return ConnectivityWidgetWrapper(
      disableInteraction: true,
      offlineWidget: OfflineWidget(),
      child: WillPopScope(
        onWillPop: () => Get.off(WellnessCart()),
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
                          onPressed: () => Get.back(), //replaces the screen to Main dashboard
                          color: Colors.white,
                        )
                      : IconButton(
                          icon: Icon(Icons.arrow_back_ios),
                          onPressed: () => Navigator.of(context).pushReplacementNamed(
                              Routes.WellnessCart), //replaces the screen to Main dashboard
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
              Visibility(
                visible: false,
                child: GestureDetector(
                  onTap: () {
                    // [GenerateNotification, SubscriptionClass, [284162999aee4fc6910118d00b9c5521], pM7UyDhBAkih16N7beZ0Rw, null]
                    s.appointmentPublish('GenerateNotification', 'SubscriptionClass',
                        ['e687db722089467cb492a6ac240b0707'], 'M1ZDc8bNE0KpHcDysxSg3g', 'null');
                    // [GenerateNotification, SubscriptionClass, [e687db722089467cb492a6ac240b0707], M1ZDc8bNE0KpHcDysxSg3g, null]
                  },
                  child: Text('publish subscription '),
                ),
              ),
              SizedBox(
                height: 40,
              )
            ],
          ),
          body: !isUpdated
              ? Padding(
                  padding: EdgeInsets.only(top: MediaQuery.of(context).size.width * 0.4),
                  child: Center(child: CircularProgressIndicator()))
              : Column(
                  children: [PastExpiredSubscriptions(), ActiveSubscriptions()],
                ),
        ),
      ),
    );
  }
}
