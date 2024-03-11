import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../Modules/online_class/about_class.dart';
import '../../../../../Modules/online_class/bloc/trainer_status/bloc/trainer_bloc.dart';
import '../../../../../Modules/online_class/functionalities/upcoming_courses.dart';
import '../../../../../Modules/online_class/presentation/pages/reviews_and_ratings.dart';
import '../../../../../Modules/online_class/presentation/widgets/join_call_widget.dart';
import '../../../../../constants/spKeys.dart';
import '../../../../../models/invoice.dart';
import '../../../../../repositories/api_consult.dart';
import '../../../../../utils/SpUtil.dart';
import '../../../../../views/teleconsultation/videocall/CallWaitingScreen.dart';
import '../../../../../views/view_past_bill/view_subscription_invoice.dart';
import '../../../../../widgets/teleconsulation/selectClassSlot.dart';
import '../../../../app/utils/appColors.dart';
import '../../../../app/utils/localStorageKeys.dart';
import '../../../../app/utils/textStyle.dart';
import '../../../../data/providers/network/api_provider.dart';
import '../../../../data/providers/network/apis/classImageApi/classImageApi.dart';
import '../../../../presentation/clippath/subscriptionTagClipPath.dart';
import '../../../../presentation/pages/dashboard/common_screen_for_navigation.dart';
import '../../bloc/search_animation_bloc/courseDetailBloc/courseDetailBloc.dart';
import '../../data/model/get_subscribtion_list.dart';
import '../../functionalities/online_services_dashboard_functionalities.dart';
import 'package:permission_handler/permission_handler.dart';

class BookClassAfterSubscription extends StatelessWidget {
  Subscription classDetail;
  Widget joinCallWidget;
  BookClassAfterSubscription({Key key, @required this.classDetail, @required this.joinCallWidget})
      : super(key: key);
  final OnlineServicesFunctions _onlineServicesFunction = OnlineServicesFunctions();
  @override
  Widget build(BuildContext context) {
    // Assuming _onlineServicesFunction is an instance of the class containing the parseCourseDurationYYMMDD method.
    // classDetail is an instance of the class containing the courseDuration property.
    // Parse start and end dates
    final DateTime parseStartDate =
        _onlineServicesFunction.parseCourseDurationYYMMDD(classDetail.courseDuration)[0];
    final DateTime parseEndDate =
        _onlineServicesFunction.parseCourseDurationYYMMDD(classDetail.courseDuration)[1];

    // Create formatted date strings
    final String startDateString =
        "${parseStartDate.day}-${parseStartDate.month}-${parseStartDate.year}";
    final String endDateString = "${parseEndDate.day}-${parseEndDate.month}-${parseEndDate.year}";
    return BlocBuilder<CourseDetailBloc, CourseDetailState>(
        builder: (BuildContext context, CourseDetailState courseDetailState) {
      return CommonScreenForNavigation(
          appBar: AppBar(
            backgroundColor: AppColors.primaryColor,
            elevation: 0,
            centerTitle: true,
            title: const Text("Class Detail", style: TextStyle(color: Colors.white)),
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
          content: SingleChildScrollView(
            child: Column(
              children: [
                // Widget for Class Detail with join button
                Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 10.0),
                      child: Container(
                        height: 57.h,
                        width: 96.w,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(8),
                            topRight: Radius.circular(8),
                            bottomLeft: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                          ),
                          color: Colors.white,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            SizedBox(
                              height: 3.h,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 5.w),
                              child: Text(
                                classDetail.title.capitalizeFirst,
                                style: AppTextStyles.primaryColorText,
                              ),
                            ),
                            SizedBox(
                              height: 2.h,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4.0, left: 4.0, right: 4.0),
                              child: SizedBox(
                                width: 82.w,
                                child: Column(children: [
                                  Row(
                                    children: [
                                      const Text("Trainer"),
                                      SizedBox(
                                        width: 20.w,
                                      ),
                                      Text(classDetail.consultantName)
                                    ],
                                  ),
                                  const Divider(
                                    color: Colors.black,
                                  ),
                                  Row(
                                    children: [
                                      const Text("Duration"),
                                      SizedBox(
                                        width: 17.5.w,
                                      ),
                                      Text("$startDateString to $endDateString")
                                    ],
                                  ),
                                  const Divider(
                                    color: Colors.black,
                                  ),
                                  // Row(
                                  //   children: [
                                  //     const Text("Status"),
                                  //     SizedBox(
                                  //       width: 20.w,
                                  //     ),
                                  //     Text(classDetail.consultantName)
                                  //   ],
                                  // ),
                                  // const Divider(
                                  //   color: Colors.black,
                                  // ),
                                  Row(
                                    children: [
                                      const Text("Timings"),
                                      SizedBox(
                                        width: 18.w,
                                      ),
                                      Text(classDetail.courseTime)
                                    ],
                                  ),
                                  const Divider(
                                    color: Colors.black,
                                  ),
                                ]),
                              ),
                            ),
                            courseDetailState is CourseDetailLoadedState
                                ? Visibility(
                                    visible: classDetail.courseFees == 0 &&
                                        courseDetailState.courseFees == 0,
                                    // if the class has fee we are showing this widget
                                    replacement: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        const Spacer(flex: 2),
                                        streamWidget(),
                                        // BlocProvider(
                                        //   create: (BuildContext context) =>
                                        //       TrainerBloc()..add(ListenTrainerStatusEvent(false)),
                                        //   child: Container(
                                        //     padding: const EdgeInsets.all(8),
                                        //     // child: joinCallWidget,
                                        //     child: joinCallwidget(
                                        //       subcriptionList: classDetail,
                                        //       ui: const Text('data'),
                                        //       noTime: true,
                                        //     ),
                                        //   ),
                                        // ),
                                        const Spacer(flex: 1),
                                        ElevatedButton(
                                          style: ButtonStyle(
                                              shape: MaterialStateProperty.all<OutlinedBorder>(
                                                RoundedRectangleBorder(
                                                  side: const BorderSide(
                                                    color: AppColors
                                                        .primaryAccentColor, // Change the color to the desired border color
                                                    width: 2.0, // Set the border width
                                                  ),
                                                  borderRadius: BorderRadius.circular(
                                                      2.0), // Adjust the border radius
                                                ),
                                              ),
                                              backgroundColor: MaterialStateProperty.all<Color>(
                                                  AppColors.plainColor)),
                                          onPressed: () async {
                                            var currentSubscription = await getDataSubID(
                                                subID: classDetail.subscriptionId);
                                            SharedPreferences prefs =
                                                await SharedPreferences.getInstance();
                                            String ihlId = prefs.getString("ihlUserId");
                                            Object data = prefs.get(SPKeys.userData);
                                            data =
                                                data == null || data == '' ? '{"User":{}}' : data;

                                            Map res = jsonDecode(data);
                                            var firstName = res['User']['firstName'];
                                            var lastName = res['User']['lastName'];
                                            firstName ??= "";
                                            lastName ??= "";
                                            var email = res['User']['email'];
                                            var mobile = res['User']['mobileNumber'];
                                            var address = res['User']['address'].toString();
                                            address = address == 'null' ? '' : address;
                                            var area = res['User']['area'].toString();
                                            area = area == 'null' ? '' : area;
                                            var city = res['User']['city'].toString();
                                            city = city == 'null' ? '' : city;
                                            var state = res['User']['state'].toString();
                                            state = state == 'null' ? '' : state;
                                            var pincode = res['User']['pincode'].toString();
                                            pincode = pincode == 'null' ? '' : pincode;

                                            // AwesomeNotifications().cancelAll();
                                            bool permissionGrandted = false;
                                            if (Platform.isAndroid) {
                                              final AndroidDeviceInfo deviceInfo =
                                                  await DeviceInfoPlugin().androidInfo;
                                              Map<Permission, PermissionStatus> _status;
                                              if (deviceInfo.version.sdkInt <= 32) {
                                                _status = await [Permission.storage].request();
                                              } else {
                                                _status = await [
                                                  Permission.photos,
                                                  Permission.videos
                                                ].request();
                                              }
                                              _status.forEach(
                                                  (Permission permission, PermissionStatus status) {
                                                if (status == PermissionStatus.granted) {
                                                  permissionGrandted = true;
                                                }
                                              });
                                            } else {
                                              permissionGrandted = true;
                                            }
                                            if (permissionGrandted) {
                                              // SharedPreferences prefs =
                                              //     await SharedPreferences.getInstance();
                                              prefs.setString(
                                                  "userFirstNameFromHistory", firstName);
                                              prefs.setString("userLastNameFromHistory", lastName);
                                              prefs.setString("userEmailFromHistory", email);
                                              prefs.setString("userContactFromHistory", mobile);
                                              prefs.setString(
                                                  "subsIdFromHistory", classDetail.subscriptionId);
                                              prefs.setString("useraddressFromHistory", address);
                                              prefs.setString("userareaFromHistory", area);
                                              prefs.setString("usercityFromHistory", city);
                                              prefs.setString("userstateFromHistory", state);
                                              prefs.setString("userpincodeFromHistory", pincode);
                                              Get.snackbar(
                                                '',
                                                'Invoice will be saved in your mobile!',
                                                backgroundColor: AppColors.primaryAccentColor,
                                                colorText: Colors.white,
                                                duration: const Duration(seconds: 5),
                                                isDismissible: false,
                                              );
                                              Invoice invoiceModel = await ConsultApi()
                                                  .getInvoiceNumber(
                                                      ihlId, classDetail.subscriptionId);
                                              invoiceModel.ihlInvoiceNumbers =
                                                  prefs.getString('invoice');
                                              print(invoiceModel.ihlInvoiceNumbers);
                                              Future.delayed(const Duration(seconds: 3), () {
                                                subscriptionBillView(
                                                    context,
                                                    classDetail.title,
                                                    classDetail.provider,
                                                    currentSubscription,
                                                    invoiceModel.ihlInvoiceNumbers,
                                                    invoiceModel: invoiceModel);
                                              });
                                            } else {
                                              Get.snackbar('Storage Access Denied',
                                                  'Allow Storage permission to continue',
                                                  backgroundColor: Colors.red,
                                                  colorText: Colors.white,
                                                  duration: const Duration(seconds: 5),
                                                  isDismissible: false,
                                                  mainButton: TextButton(
                                                      onPressed: () async {
                                                        await openAppSettings();
                                                      },
                                                      child: const Text('Allow')));
                                            }
                                          },
                                          child: const Text(
                                            "Download Invoice",
                                            style: TextStyle(color: Colors.black),
                                          ),
                                        ),
                                        const Spacer(
                                          flex: 2,
                                        ),
                                      ],
                                    ),
                                    //if the class has zero fee we are showing this widget
                                    child: streamWidget())
                                : Container(),
                          ],
                        ),
                      ),
                    ),
                    FutureBuilder(
                      future: ClassImage().getCourseImageURL([classDetail.courseId]),
                      builder: (BuildContext ctx, AsyncSnapshot snapshot) {
                        if (snapshot.hasData) {
                          List<String> image = snapshot.data[0]['base_64'].split(',');
                          Uint8List bytes1;
                          bytes1 = const Base64Decoder().convert(image[1].toString());
                          return bytes1 == null
                              ? const Placeholder()
                              : Padding(
                                  padding: const EdgeInsets.only(top: 15, left: 12, right: 12),
                                  child: Column(
                                    children: [
                                      Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          Container(
                                            height: 25.h,
                                            width: 94.w,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              boxShadow: [
                                                BoxShadow(
                                                    offset: const Offset(1, 1),
                                                    spreadRadius: 2,
                                                    blurRadius: 2,
                                                    color: Colors.grey.shade300)
                                              ],
                                              border: Border.all(
                                                  width: 0.7.w,
                                                  color: AppColors.primaryColor.withOpacity(0.2)),
                                              borderRadius:
                                                  const BorderRadius.all(Radius.circular(8.0)),
                                              image: DecorationImage(
                                                  image: Image.memory(
                                                    base64Decode(image[1].toString()),
                                                  ).image,
                                                  fit: BoxFit.cover),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(left: 4.0, top: 6.0),
                                            child: SizedBox(
                                              child: ClipPath(
                                                clipper: SubscriptionClipPath(),
                                                child: Container(
                                                  color: AppColors.primaryAccentColor,
                                                  child: FittedBox(
                                                    fit: BoxFit.fill,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.fromLTRB(10, 2, 8, 2),
                                                      child: Text(
                                                        classDetail.feesFor,
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontFamily: 'Poppins',
                                                            fontSize: 13.sp),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                        }
                        if (snapshot.hasError) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 15, left: 12, right: 12),
                            child: Shimmer.fromColors(
                              direction: ShimmerDirection.ltr,
                              enabled: true,
                              baseColor: Colors.white,
                              highlightColor: Colors.grey.shade300,
                              child: Container(
                                height: 25.h,
                                width: 96.w,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                          );
                        }
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 15, left: 12, right: 12),
                            child: Shimmer.fromColors(
                              direction: ShimmerDirection.ltr,
                              enabled: true,
                              baseColor: Colors.white,
                              highlightColor: Colors.grey.shade400,
                              child: Container(
                                height: 25.h,
                                width: 96.w,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                      width: 0.7.w, color: AppColors.primaryColor.withOpacity(0.2)),
                                  borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                                ),
                              ),
                            ),
                          );
                          // return Container(
                          //   child: Center(
                          //     child: CircularProgressIndicator(),
                          //   ),
                          // );
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 15, left: 12, right: 12),
                          child: Shimmer.fromColors(
                            baseColor: Colors.white,
                            direction: ShimmerDirection.ltr,
                            highlightColor: Colors.grey.withOpacity(0.2),
                            child: Container(
                              height: 25.h,
                              width: 95.w,
                              decoration: BoxDecoration(
                                border: Border.all(
                                    width: 0.7.w, color: AppColors.primaryColor.withOpacity(0.2)),
                                borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                SizedBox(
                  height: 1.h,
                ),
                courseDetailState is CourseDetailLoadedState
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: GestureDetector(
                          onTap: () {
                            Get.to(AboutClass(
                              courseId: courseDetailState.courseDetail.courseId,
                              desc: courseDetailState.courseDetail.courseDescription,
                              title: courseDetailState.courseDetail.title,
                            ));
                          },
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(8),
                                topRight: Radius.circular(8),
                                bottomLeft: Radius.circular(8),
                                bottomRight: Radius.circular(8),
                              ),
                            ),
                            height: 10.h,
                            width: 96.w,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 3.w),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.transparent,
                                        borderRadius: BorderRadius.circular(20.w)),
                                    height: 12.w,
                                    width: 12.w,
                                    padding: const EdgeInsets.all(8),
                                    child: Image.asset(
                                      'newAssets/Icons/about class.png',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 3.w),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text("About"),
                                      SizedBox(
                                          width: 55.w,
                                          child: Text(
                                              courseDetailState
                                                  .courseDetail.courseDescription.capitalizeFirst,
                                              overflow: TextOverflow.ellipsis,
                                              softWrap: false,
                                              maxLines: 1))
                                    ],
                                  ),
                                ),
                                const Spacer()
                              ],
                            ),
                          ),
                        ),
                      )
                    : courseDetailState is CourseDetailInitialState
                        ? Shimmer.fromColors(
                            baseColor: Colors.grey.withOpacity(0.04),
                            highlightColor: AppColors.primaryColor.withOpacity(0.4),
                            child: Container(
                              height: 10.h,
                              width: 96.w,
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(8),
                                    topRight: Radius.circular(50),
                                    bottomLeft: Radius.circular(8),
                                    bottomRight: Radius.circular(8)),
                                boxShadow: [
                                  BoxShadow(
                                      blurRadius: 4,
                                      offset: const Offset(1, 1),
                                      color: Colors.grey.shade400)
                                ],
                                color: Colors.white,
                              ),
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.white,
                              ),
                              height: 10.h,
                              width: 96.w,
                              child: Row(
                                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(width: 2.w),
                                  Container(
                                    decoration: BoxDecoration(
                                        color: Colors.transparent,
                                        borderRadius: BorderRadius.circular(20.w)),
                                    height: 12.w,
                                    width: 12.w,
                                    padding: const EdgeInsets.all(8),
                                    child: Image.asset(
                                      'newAssets/Icons/about class.png',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  SizedBox(width: 2.w),
                                  courseDetailState is CourseDetailErrorState
                                      ? const Text("Server Error")
                                      : Container()
                                ],
                              ),
                            ),
                          ),
                SizedBox(
                  height: 1.h,
                ),
                courseDetailState is CourseDetailLoadedState
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: GestureDetector(
                          onTap: () {
                            Get.to(ReviewsAndRatings(
                              ratings: courseDetailState.courseDetail.ratings.toString(),
                              ratingsList: courseDetailState.courseDetail.textReviewsData,
                            ));
                          },
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(8),
                                topRight: Radius.circular(8),
                                bottomLeft: Radius.circular(8),
                                bottomRight: Radius.circular(8),
                              ),
                            ),
                            height: 10.h,
                            width: 96.w,
                            child: Row(
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 3.w),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.transparent,
                                        borderRadius: BorderRadius.circular(20.w)),
                                    height: 12.w,
                                    width: 12.w,
                                    padding: const EdgeInsets.all(8),
                                    child: Image.asset(
                                      'newAssets/Icons/class rating.png',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 3.w),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text("Reviews & Ratings"),
                                      SizedBox(
                                        height: 1.h,
                                      ),
                                      SizedBox(
                                        width: 55.w,
                                        child: RatingBar.builder(
                                          ignoreGestures: true,
                                          initialRating:
                                              courseDetailState.courseDetail.ratings.toDouble(),
                                          minRating: 0,
                                          itemSize: 2.5.h,
                                          direction: Axis.horizontal,
                                          allowHalfRating: false,
                                          itemCount: 5,
                                          itemPadding: const EdgeInsets.symmetric(horizontal: 2.0),
                                          itemBuilder: (BuildContext context, _) => const Icon(
                                            Icons.star,
                                            color: Colors.amberAccent,
                                          ),
                                          onRatingUpdate: (double value) {},
                                        ),
                                        // child: Text(courseDetailState.courseDetail.courseDescription,
                                        //     softWrap: false,maxLines:1)
                                      )
                                    ],
                                  ),
                                ),
                                const Spacer()
                              ],
                            ),
                          ),
                        ),
                      )
                    : courseDetailState is CourseDetailInitialState
                        ? Shimmer.fromColors(
                            baseColor: Colors.grey.withOpacity(0.04),
                            highlightColor: AppColors.primaryColor.withOpacity(0.4),
                            child: Container(
                              height: 10.h,
                              width: 96.w,
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(8),
                                    topRight: Radius.circular(50),
                                    bottomLeft: Radius.circular(8),
                                    bottomRight: Radius.circular(8)),
                                boxShadow: [
                                  BoxShadow(
                                      blurRadius: 4,
                                      offset: const Offset(1, 1),
                                      color: Colors.grey.shade400)
                                ],
                                color: Colors.white,
                              ),
                            ),
                          )
                        : Container(
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(8),
                                topRight: Radius.circular(8),
                                bottomLeft: Radius.circular(8),
                                bottomRight: Radius.circular(8),
                              ),
                            ),
                            height: 10.h,
                            width: 96.w,
                            child: Row(
                              // mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                SizedBox(width: 2.w),
                                Container(
                                  decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      borderRadius: BorderRadius.circular(20.w)),
                                  height: 12.w,
                                  width: 12.w,
                                  padding: const EdgeInsets.all(8),
                                  child: Image.asset(
                                    'newAssets/Icons/class rating.png',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                SizedBox(width: 2.w),
                                courseDetailState is CourseDetailErrorState
                                    ? const Text("Server Error")
                                    : Container()
                              ],
                            ),
                          ),
                SizedBox(
                  height: 20.h,
                ),
              ],
            ),
          ));
    });
  }

  Widget streamWidget() {
    //the below code will return the join now button which has the lots conditions and functinolaties
    return Container(
        padding: const EdgeInsets.all(8),
        child: StreamBuilder<DocumentSnapshot>(
          stream:
              FireStoreCollections.consultantOnlineStatus.doc(classDetail.consultantId).snapshots(),
          builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const ElevatedButton(onPressed: null, child: Text("Join Now"));
            }
            if (!snapshot.data.exists ?? true) {
              FireStoreCollections.consultantOnlineStatus.doc().set(
                  <String, String>{'consultantId': classDetail.consultantId, 'status': "Offline"});
            }
            Map data = snapshot.data.data() as Map;
            String status = "Offline";
            if (data != null) {
              status = data['status'];
            } else {
              debugPrint("Doc status doesn't exist");
            }
            bool externalUrlIsNull =
                classDetail.externalUrl == null || classDetail.externalUrl == "";
            if (joinButtonconditions(
                    duration: classDetail.courseDuration,
                    courseTime: OnlineServicesFunctions().adjustHourLength(classDetail.courseTime),
                    trainerStatus: status,
                    courseType: classDetail.courseType,
                    courseOn:
                        classDetail.courseOn.isNotEmpty ? classDetail.courseOn.first : "Monday") &&
                externalUrlIsNull) {
              return ElevatedButton(
                  onPressed: () async {
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    var userID = prefs.getString("userID");
                    prefs.setString(
                        "userIDFromSubscriptionCall", userID ?? SpUtil.getString(LSKeys.ihlUserId));
                    prefs.setString("consultantIDFromSubscriptionCall", classDetail.consultantId);
                    prefs.setString(
                        "subscriptionIDFromSubscriptionCall", classDetail.subscriptionId);
                    prefs.setString("courseNameFromSubscriptionCall", classDetail.title);
                    prefs.setString("courseIDFromSubscriptionCall", classDetail.courseId);
                    prefs.setString("trainerNameFromSubscriptionCall", classDetail.consultantName);
                    prefs.setString('providerFromSubscriptionCall', classDetail.provider);
                    Get.to(CallWaitingScreen(
                      appointmentDetails: <dynamic>[
                        classDetail.courseId,
                        userID,
                        classDetail.consultantId,
                        "SubscriptionCall",
                        classDetail.consultantId,
                      ],
                    ));
                  },
                  child: const Text("Join Now"));
            } else if (joinButtonconditions(
                externalUrl: externalUrlIsNull,
                duration: classDetail.courseDuration,
                courseTime: OnlineServicesFunctions().adjustHourLength(classDetail.courseTime),
                trainerStatus: status,
                courseType: classDetail.courseType,
                courseOn:
                    classDetail.courseOn.isNotEmpty ? classDetail.courseOn.first : "Monday")) {
              return ElevatedButton(
                  onPressed: () async {
                    Uri url = Uri.parse(classDetail.externalUrl);
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  },
                  child: const Text("Join No"));
            } else {
              return const ElevatedButton(onPressed: null, child: Text("Join Now"));
            }
          },
        ));
  }

//The below function is about join button enable using the class details such as timing , course on ,
//duration and the trainner online and offline status.
  bool joinButtonconditions(
      {String duration,
      String courseTime,
      String trainerStatus,
      String courseType,
      String courseOn,
      bool externalUrl = true}) {
    try {
      if (externalUrl == false) {
        trainerStatus = "Online";
      }
      int differenceInDays;
      int differenceInTime;
      // by unslash the bottom code you can easily hardcode it
      // String duration = "2023-11-06 - 2024-01-04";
      // String courseTime = "12:01 PM - 12:30 PM";
      // String trainerStatus = "Online";
      // String courseType = "60 Days";
      // String courseOn = "Monday";
      DateTime currentDateTime = DateTime.now();
      String courseDurationFromApi = duration;
      String courseTimeFromApi = courseTime;
      String courseStartTime;
      String courseEndTime;
      var splitDuration = courseDurationFromApi.split(" - ");
      String courseStartDuration = splitDuration[0];

      String courseEndDuration = splitDuration[1];

      DateTime startDate = DateFormat("yyyy-MM-dd").parse(courseStartDuration);
      final DateFormat formatter = DateFormat('yyyy-MM-dd');
      String startDateFormattedToString = formatter.format(startDate);

      DateTime endDate = DateFormat("yyyy-MM-dd").parse(courseEndDuration);
      String endDateFormattedToString = formatter.format(endDate);

      if (courseTimeFromApi[2].toString() == ':' && courseTimeFromApi[13].toString() != ':') {
        String tempcourseEndTime = '';
        courseStartTime = courseTimeFromApi.substring(0, 8);
        for (int i = 0; i < courseTimeFromApi.length; i++) {
          if (i == 10) {
            tempcourseEndTime += '0';
          } else if (i > 10) {
            tempcourseEndTime += courseTimeFromApi[i];
          }
        }
        courseEndTime = tempcourseEndTime;
      } else if (courseTimeFromApi[2].toString() != ':') {
        String tempcourseStartTime = '';
        String tempcourseEndTime = '';

        for (int i = 0; i < courseTimeFromApi.length; i++) {
          if (i == 0) {
            tempcourseStartTime = '0';
          } else if (i > 0 && i < 8) {
            tempcourseStartTime += courseTimeFromApi[i - 1];
          } else if (i > 9) {
            tempcourseEndTime += courseTimeFromApi[i];
          }
        }
        courseStartTime = tempcourseStartTime;
        courseEndTime = tempcourseEndTime;
        if (courseEndTime[2].toString() != ':') {
          String tempcourseEndTime = '';
          for (int i = 0; i <= courseEndTime.length; i++) {
            if (i == 0) {
              tempcourseEndTime += '0';
            } else {
              tempcourseEndTime += courseEndTime[i - 1];
            }
          }
          courseEndTime = tempcourseEndTime;
        }
      } else {
        courseStartTime = courseTimeFromApi.substring(0, 8);
        courseEndTime = courseTimeFromApi.substring(11, 19);
      }
      DateTime startTime = DateFormat.jm().parse(courseStartTime);
      DateTime endTime = DateFormat.jm().parse(courseEndTime);

      String startingTime = DateFormat("HH:mm:ss").format(startTime);
      String endingTime = DateFormat("HH:mm:ss").format(endTime);
      String startDateAndTime = "$startDateFormattedToString $startingTime";
      String endDateAndTime = "$endDateFormattedToString $endingTime";
      DateTime finalStartDateTime = DateFormat("yyyy-MM-dd HH:mm:ss").parse(startDateAndTime);
      DateTime finalEndDateTime = DateFormat("yyyy-MM-dd HH:mm:ss").parse(endDateAndTime);

      ///from here
      DateTime todaysDate = DateFormat("yyyy-MM-dd").parse(DateTime.now().toString());
      String formattedTodaysDate = formatter.format(todaysDate);
      String startTimeWithTodaysDateString = "$formattedTodaysDate $startingTime";
      String endTimeWithTodaysDateString = "$formattedTodaysDate $endingTime";
      DateTime TodaysDateWithStartTime = DateFormat("yyyy-MM-dd HH:mm:ss")
          .parse(startTimeWithTodaysDateString)
          .subtract(const Duration(minutes: 0));
      DateTime TodaysDateWithEndTime =
          DateFormat("yyyy-MM-dd HH:mm:ss").parse(endTimeWithTodaysDateString);
      DateTime startTimeOnly = DateFormat("HH:mm:ss").parse(startingTime);
      DateTime endTimeOnly = DateFormat("HH:mm:ss").parse(endingTime);
      DateTime classStartingTime = DateTime.parse(startDateAndTime);
      differenceInTime = endTime.difference(startTime).inMinutes;
      differenceInDays = endDate.difference(startDate).inDays;
      DateTime fiveMinutesBeforeStartTime = finalStartDateTime.subtract(const Duration(minutes: 5));
      DateTime minutesAfterStartTime = classStartingTime.add(Duration(minutes: differenceInTime));
      if ((currentDateTime.isBefore(finalEndDateTime) &&
              currentDateTime.isAfter(fiveMinutesBeforeStartTime)) &&
          (currentDateTime.isAfter(TodaysDateWithStartTime) &&
              currentDateTime.isBefore(TodaysDateWithEndTime)) &&
          (trainerStatus == "Online" || trainerStatus == "Busy") &&
          (
              // courseType.toLowerCase() == "daily" ||
              (courseOn.contains("Monday") ||
                  courseOn.contains("Tuesday") ||
                  courseOn.contains("Wednesday") ||
                  courseOn.contains("Thursday") ||
                  courseOn.contains("Friday") ||
                  courseOn.contains("Saturday") ||
                  courseOn.contains("Sunday")))) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
