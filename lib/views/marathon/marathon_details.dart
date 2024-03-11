import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:ihl/new_design/presentation/pages/home/home_view.dart';
import 'package:ihl/new_design/presentation/pages/home/landingPage.dart';
import 'package:ihl/repositories/marathon_event_api.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/utils/screenutil.dart';
import 'package:ihl/views/home_screen.dart';
import 'package:ihl/views/marathon/dashboard_marathonCard.dart';
import 'package:ihl/views/marathon/register_user.dart';
import 'package:ihl/views/splash_screen.dart';
import 'package:ihl/widgets/BasicPageUI.dart';
import 'package:ihl/widgets/event_basic_ui.dart';
import 'package:ihl/widgets/offline_widget.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:lottie/lottie.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'e-cetificate_image.dart';

// String hoursStr = '00';
ValueNotifier<int> hoursStr = ValueNotifier<int>(0);
// String minutesStr = '00';
var minutesStr = ValueNotifier<int>(0);
// String secondsStr = '00';
ValueNotifier<int> secondsStr = ValueNotifier<int>(0);
// String onPauseHoursStr = '00';
ValueNotifier<int> onPauseHoursStr = ValueNotifier<int>(0);
// String onPauseMinutesStr = '00';
ValueNotifier<int> onPauseMinutesStr = ValueNotifier<int>(0);
// String onPauseSecondsStr = '00';
ValueNotifier<int> onPauseSecondsStr = ValueNotifier<int>(0);
ValueNotifier<int> todaySteps = ValueNotifier<int>(0);

bool isCalled = false;
var pauseDur;
var storedDur;
bool pauseValue = true;
bool stopValue = false;
bool flag = true;
bool onPauseAvailable = false;
var event_iHL_User_Id;
double totalDistance = 0;
var variantsList = [];
String progressTIME = '1800-01-01 00:00:00';
var event_end_time = '';

class MarathonDetails extends StatefulWidget {
  MarathonDetails(
      {this.img,
      this.name,
      this.description,
      this.eventDetailList,
      this.start,
      this.userEnrolledMap,
      this.pauseOrResume,
      this.indexed});
  final img;
  final name;
  final description;
  final eventDetailList;
  final start;
  final userEnrolledMap;
  final pauseOrResume;
  final indexed;
  @override
  _MarathonDetailsState createState() => _MarathonDetailsState();
}

class _MarathonDetailsState extends State<MarathonDetails> {
  String value;
  String eventName = '';
  String eventLocation = '';
  String eventDate = '';
  String eventImg = '';
  String eventDescription = '';

  // bool pauseValue = false;
  // bool stopValue = false;
  // ///timer stopwatch vars
  // bool flag = true;
  // bool onPauseAvailable = false;
  // Stream<int> timerStream;
  // StreamSubscription<int> timerSubscription;

  // var pauseDur;
  @override
  void initState() {
    eventName = widget.eventDetailList[widget.indexed]['event_name'].toString() +
        ' by ' +
        widget.eventDetailList[widget.indexed]['event_host'].toString();
    eventDescription = widget.eventDetailList[widget.indexed]['event_description'].toString();
    eventImg = widget.eventDetailList[widget.indexed]['event_image'].toString();
    eventLocation =
        widget.eventDetailList[widget.indexed]['event_locations'].toString().replaceAll('[', '');
    eventLocation = eventLocation.replaceAll(']', '');
    eventDate = widget.eventDetailList[widget.indexed]['event_start_time'].toString();
    var eve_date_form = DateTime.parse(eventDate);
    final DateFormat formatter = DateFormat.yMMMMd('en_US').add_jm();
    final String formatted = formatter.format(eve_date_form);
    print(formatted);
    eventDate = formatted;

    // var now = DateTime.parse(eventDate);
    // final DateFormat formatter = DateFormat.yMMMMd('en_US').add_jm();
    // final String formatted = formatter.format(now);
    // print(formatted);
    // eventDate = formatted;

    if (widget.start == true) {
      ///cancel all values if event_status = start
      if (widget.pauseOrResume == true &&
          showFromSharedPref == true &&
          widget.userEnrolledMap['event_status'] == 'pause') {
        pauseValue = true;
      } else if (widget.pauseOrResume == null &&
          showFromSharedPref == true &&
          widget.userEnrolledMap['event_status'] == 'pause') {
        pauseValue = false;
      }
      if (widget.userEnrolledMap['event_status'] == '' ||
          widget.userEnrolledMap['event_status'] == null) {
        hoursStr = ValueNotifier<int>(0);
// String minutesStr = '00';
        minutesStr = ValueNotifier<int>(0);
// String secondsStr = '00';
        secondsStr = ValueNotifier<int>(0);
// String onPauseHoursStr = '00';
        onPauseHoursStr = ValueNotifier<int>(0);
// String onPauseMinutesStr = '00';
        onPauseMinutesStr = ValueNotifier<int>(0);
// String onPauseSecondsStr = '00';
        onPauseSecondsStr = ValueNotifier<int>(0);
        todaySteps = ValueNotifier<int>(0);

        isCalled = false;
        pauseDur = null;
        storedDur = null;
        pauseValue = true;
        stopValue = false;
        flag = true;
        onPauseAvailable = false;
        event_iHL_User_Id;
        totalDistance = 0;
        variantsList = [];
        progressTIME = '1800-01-01 00:00:00';
        event_end_time = '';
        //stop the duration
        if (STR.timerStream != null) {
          STR.timerSubscription.cancel();
          STR.timerStream = null;

          ///we stop the pedeometer or stop the walker
          STR.stopListening();
        }
      }
      if (widget.userEnrolledMap['event_status'] != 'stop' &&
          widget.userEnrolledMap['event_status'] != 'complete') getSavedDataAndStartAgain();

      totalDistance =
          double.parse(widget.userEnrolledMap['event_varient'].toString().replaceAll('Km', ''));
      // variantsList = widget.eventDetailList[widget.indexed]['event_varients'];
      var variantsList1 = widget.eventDetailList[widget.indexed]['event_varients'];
      variantsList1.forEach((element) {
        element = element.toString().replaceAll('Kms', '');
        variantsList.add(double.parse(element.toString().replaceAll('Km', '')));
      });
      print(variantsList);
      if (isCalled == false) {
        if (widget.userEnrolledMap['event_status'] != 'stop' &&
            widget.userEnrolledMap['event_status'] != 'complete' &&
            widget.userEnrolledMap['event_status'] != 'pause') {
          checkPermission(event_status: 'start');
        }
        isCalled = true;
      }
      event_end_time = widget.eventDetailList[widget.indexed]['event_end_time'];
    }

    // startt();
    // timeOut();
    super.initState();
  }

  cancelAllValues() async {}

  checkPermission({event_status}) async {
    // await Permission.activityRecognition.request();
    var status = await Permission.activityRecognition.status;
    if (status.isGranted) {
      await STR.startt('$event_status', widget.eventDetailList[widget.indexed]['event_id']);
      await STR.initPlatformState();
    } else if (status.isDenied) {
      await Permission.activityRecognition.request();
      status = await Permission.activityRecognition.status;
      if (status.isGranted) {
        await STR.startt('$event_status', widget.eventDetailList[widget.indexed]['event_id']);
        await STR.initPlatformState();
      } else {
        Get.snackbar('Activity Access Denied', 'Allow Activity permission to continue',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: Duration(seconds: 5),
            isDismissible: false,
            mainButton: TextButton(
                //TextButton(
                // style: TextButton
                //     .styleFrom(
                //   primary:
                //       Colors.white,
                // ),
                onPressed: () async {
                  await openAppSettings();
                },
                child: Text('Allow')));
      }
    } else {
      Get.snackbar('Activity Access Denied', 'Allow Activity permission to continue',
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

  getSavedDataAndStartAgain() async {
    // var ddd = widget.userEnrolledMap['progress_time'].toString();
    // var ab = ddd.substring(11,19);
    // var str = DateTime.parse(ddd);
    // print(str);
    // final DateFormat fff = DateFormat('yyyy-MM-dd hh:mm:ss');
    // final String fmt = fff.format(str);
    // print('####################################################################'+fmt);
    // var str1 = fmt.split(' ');
    // // var timeList = str[1].split(':');
    // // var timeList = str1[1].split(':');
    // var timeList = ab.split(':');
    // apiHoursStr.value = int.parse(timeList[widget.indexed]);
    // apiMinutesStr.value = int.parse(timeList[1]);
    // apiSecondsStr.value = int.parse(timeList[2]);
    var prefs = await SharedPreferences.getInstance();
    var data1 = prefs.get('data');
    Map res = jsonDecode(data1);
    event_iHL_User_Id = res['User']['id'];
    var e_steps = prefs.getString('event_steps');
    var e_seconds = prefs.getString('event_seconds');
    var e_distance = prefs.getString('event_distance');
    var e_status = prefs.getString('event_status');
    // Get.snackbar('after shareD Pref result', e_seconds.toString());
    // Get.snackbar('after shareD Pref result', e_seconds.toString(),backgroundColor: Colors.red);
    if (e_seconds != null && showFromSharedPref == true && e_seconds != '0') {
      // Get.snackbar('after shareD Pref result', e_seconds.toString(),backgroundColor: Colors.white70);
      pauseDur = int.parse(e_seconds);
      onPauseAvailable = true;
      // storedDur = 0;//int.parse(e_seconds);
      //if e_status pause than we will not automatically start the watch and step only give value
      if (isCalled == false && widget.userEnrolledMap['event_status'] != 'pause') {
        // print('called from the function !!!!!!!!iiiii!!!!!=> getSavedDataAndStartAgain ');
        STR.startt('progress', widget.eventDetailList[widget.indexed]['event_id']);
        STR.initPlatformState();
        isCalled = true;
      }
      if (widget.userEnrolledMap['event_status'] == 'pause') {}

      /// todo: call the track record api with status progress
      // DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
      // String e_timing = dateFormat.format(DateTime.now());
      String e_timing = await STR.getProgresstimes(
          hoursStr.value.toString(), minutesStr.value.toString(), secondsStr.value.toString());
      if (widget.userEnrolledMap['event_status'] != 'pause') {
        trackProgressApi(
            event_id: widget.eventDetailList[widget.indexed]['event_id'],
            ihl_user_id: event_iHL_User_Id,
            steps: e_steps,
            distance_covered: e_distance,
            event_status: e_status,
            start_time: '',
            progress_time: e_timing);
      }
    }
  }

  @override
  var renderOverlay = true;
  var visible = true;
  var switchLabelPosition = false;
  var extend = false;
  var rmicons = false;
  var customDialRoot = false;
  var closeManually = false;
  var useRAnimation = true;
  var isDialOpen = ValueNotifier<bool>(false);
  // var speedDialDirection = SpeedDialDirection.up;
  var buttonSize = const Size(56.0, 56.0);
  var childrenButtonSize = const Size(56.0, 56.0);
  // var buttonSize = const Size(56.0, 56.0);
  // var childrenButtonSize = const Size(56.0, 56.0);
  Widget build(BuildContext context) {
    ScUtil.init(context, width: 360, height: 640, allowFontScaling: true);
    if (!widget.start) {
      return ConnectivityWidgetWrapper(
        disableInteraction: true,
        offlineWidget: OfflineWidget(),
        child: WillPopScope(
          onWillPop: () {
            // showFromSharedPref=false;
            // Get.back();
            showFromSharedPref = false;
            Get.off(LandingPage());
          },
          child: BasicPageUI(
            appBar: Column(
              children: [
                // SizedBox(
                //   width: ScUtil().setWidth(20),
                // ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: ScUtil().setWidth(10),
                    ),
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios),
                      onPressed: () {
                        // Get.back();
                        showFromSharedPref = false;
                        Get.off(LandingPage());
                      }, //replaces the screen to Main dashboard
                      color: Colors.white,
                    ),
                    SizedBox(
                      width: ScUtil().setWidth(50),
                    ),
                    Text(
                      'Event Details',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: ScUtil().setSp(20),
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.7,
                        // height: 4
                      ),
                      // style: TextStyle(
                      //     color: Colors.white, fontSize: ScUtil().setSp(20.0)),
                    ),
                  ],
                ),
              ],
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Container(
                  // width: ScUtil().setWidth(),
                  //width: MediaQuery.of(context).size.width,
                  // height: MediaQuery.of(context).size.height / 1,
                  //height: ScUtil().setHeight(600),
                  decoration: BoxDecoration(
                    // color: Colors.tealAccent,
                    // color: Color.fromRGBO(35, 107, 254, 0.6),
                    // color: AppColors.primaryAccentColor,
                    color: FitnessAppTheme.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
                          // height: MediaQuery.of(context).size.height / 4,
                          width: MediaQuery.of(context).size.width,
                          // width: ScUtil().setWidth(),
                          height: ScUtil().setHeight(180),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.network(widget.img ?? widget.img),
                            // child: Image.asset(
                            //   'assets/images/marathon2.jpg',
                            //   fit: BoxFit.cover,
                            // ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Container(
                          child: Text(
                            '${widget.name}',
                            // "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.",
                            style: TextStyle(
                              //color: Colors.white,
                              color: AppColors.appTextColor,
                              fontSize: ScUtil().setSp(16),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Container(
                          child: Text(
                            '${widget.description}',
                            // "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.",
                            style: TextStyle(
                              // color: Colors.white,
                              color: AppColors.appTextColor,
                              fontSize: ScUtil().setSp(16),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      //SizedBox(height: ScUtil().setHeight(220),),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            backgroundColor: Colors.black.withOpacity(0.7),
                            textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          onPressed: () {
                            Get.to(UserRegister(
                              eventDetailList: widget.eventDetailList,
                            ));
                          },
                          child: Text(
                            'Register For Free now',
                            style: TextStyle(
                                color: Colors.white70,
                                letterSpacing: 1.5,
                                fontSize: ScUtil().setSp(14)),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    } else if (widget.start) {
      return ConnectivityWidgetWrapper(
        disableInteraction: true,
        offlineWidget: OfflineWidget(),
        child: WillPopScope(
          onWillPop: () async {
            if (isDialOpen.value == true) {
              isDialOpen.value = false;
              return await false;
            }
            if (isDialOpen.value == false) {
              showFromSharedPref = false;
              Get.off(LandingPage());
            }
          },
          child: EventPageUI(
            // floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
            floatingActionButton: (widget.userEnrolledMap['event_status'] != 'stop' &&
                    widget.userEnrolledMap['event_status'] != 'complete')
                ? null
                : SpeedDial(
                    backgroundColor: Colors.orangeAccent.shade200,
                    // animatedIcon: AnimatedIcons.menu_close,
                    // animatedIconTheme: IconThemeData(size: 22.0),
                    // / This is ignored if animatedIcon is non null
                    // child: Text("open"),
                    // activeChild: Text("close"),
                    icon: Icons.description,
                    activeIcon: Icons.description_outlined,
                    spacing: 3,
                    openCloseDial: isDialOpen,
                    childPadding: const EdgeInsets.all(5),
                    spaceBetweenChildren: 4,
                    dialRoot: customDialRoot
                        ? (ctx, open, toggleChildren) {
                            return ElevatedButton(
                              onPressed: toggleChildren,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[900],
                                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
                              ),
                              child: const Text(
                                "Download",
                                style: TextStyle(fontSize: 17),
                              ),
                            );
                          }
                        : null,
                    // buttonSize: buttonSize, // it's the SpeedDial size which defaults to 56 itself
                    // iconTheme: IconThemeData(size: 22),
                    label: extend ? const Text("Open") : null, // The label of the main button.
                    /// The active label of the main button, Defaults to label if not specified.
                    activeLabel: extend ? const Text("Close") : null,

                    /// Transition Builder between label and activeLabel, defaults to FadeTransition.
                    // labelTransitionBuilder: (widget, animation) => ScaleTransition(scale: animation,child: widget),
                    /// The below button size defaults to 56 itself, its the SpeedDial childrens size
                    // childrenButtonSize: childrenButtonSize,
                    visible: visible,
                    // direction: speedDialDirection,
                    switchLabelPosition: switchLabelPosition,

                    /// If true user is forced to close dial manually
                    closeManually: closeManually,

                    /// If false, backgroundOverlay will not be rendered.
                    renderOverlay: renderOverlay,
                    // overlayColor: Colors.black,
                    // overlayOpacity: 0.5,
                    onOpen: () => debugPrint('OPENING DIAL'),
                    onClose: () => debugPrint('DIAL CLOSED'),
                    useRotationAnimation: useRAnimation,
                    tooltip: 'Share Pictures',
                    heroTag: 'speed-dial-hero-tag',
                    // foregroundColor: Colors.black,
                    // backgroundColor: Colors.white,
                    // activeForegroundColor: Colors.red,
                    // activeBackgroundColor: Colors.blue,
                    elevation: 8.0,
                    isOpenOnStart: false,
                    animationDuration: const Duration(milliseconds: 200),
                    shape: customDialRoot ? const RoundedRectangleBorder() : const StadiumBorder(),
                    // childMargin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    children: [
                      SpeedDialChild(
                        child: const Icon(Icons.download),
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        label: 'E - Certificate',
                        onTap: () async {
                          var name = widget.userEnrolledMap['user_name'] == null
                              ? "Name"
                              : widget.userEnrolledMap['user_name'];
                          var status = widget.userEnrolledMap['event_status'] == null
                              ? "completed"
                              : widget.userEnrolledMap['event_status'];
                          var varient = widget.userEnrolledMap['event_varient'] == null
                              ? "5 KM"
                              : widget.userEnrolledMap['event_varient'];
                          var time_text = widget.userEnrolledMap['closed_time_by_user'] == null
                              ? "2022-01-01'T'01:33:06.000'Z"
                              : widget.userEnrolledMap['closed_time_by_user'];
                          var employee_id = widget.userEnrolledMap['employee_id'] == null
                              ? "001"
                              : widget.userEnrolledMap['employee_id'];
                          DateTime dateTime =
                              new DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z").parse(time_text);
                          var completed_time =
                              DateFormat('hh:mm a').format(DateTime.parse(dateTime.toString()));
                          Get.to(EcertificateImage(
                              name_participent: name,
                              event_status: status,
                              event_varient: varient,
                              time_taken: completed_time,
                              emp_id: employee_id));
                        },
                        onLongPress: () => debugPrint('E - Certificate'),
                      ),

                      SpeedDialChild(
                        child: const Icon(Icons.cloud_upload_outlined),
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                        label: 'Upload Picture',
                        visible: true,
                        // onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                        //     const SnackBar(content: Text(("Third Child Pressed"))),
                        // ),
                        onTap: () async {
                          sheetForSelectingReport(context);
                        },
                        onLongPress: () => debugPrint('Upload Picture'),
                      ),
                      // SpeedDialChild(
                      //   child: !rmicons ? const Icon(Icons.brush) : null,
                      //   backgroundColor: Colors.deepOrange,
                      //   foregroundColor: Colors.white,
                      //   label: 'Second',
                      //   onTap: () => debugPrint('SECOND CHILD'),
                      // ),
                    ],
                  ),
            appBar: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: ScUtil().setWidth(10),
                    ),
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios),
                      onPressed: () {
                        // Get.back();
                        showFromSharedPref = false;
                        Get.off(LandingPage());
                      }, //replaces the screen to Main dashboard
                      color: Colors.white,
                    ),
                    SizedBox(
                      width: ScUtil().setWidth(40),
                    ),
                    Text(
                      'Event Tracker',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: ScUtil().setSp(20),
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.7,
                        // height: 4
                      ),
                      // style: TextStyle(
                      //     color: Colors.white, fontSize: ScUtil().setSp(20.0)),
                    ),
                  ],
                ),
                SizedBox(
                  height: ScUtil().setHeight(25),
                )
              ],
            ),
            body: SingleChildScrollView(
              child: Container(
                // width: ScUtil().setWidth(),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                // height: ScUtil().setHeight(600),
                decoration: BoxDecoration(
                  // color: Colors.tealAccent,
                  color: Color.fromRGBO(35, 107, 254, 0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // Padding(
                    //   padding: const EdgeInsets.all(8.0),
                    //   child: Container(
                    //     decoration: BoxDecoration(
                    //         borderRadius: BorderRadius.circular(20),
                    //     image: DecorationImage(
                    //       image: NetworkImage(widget.img??widget.img,),
                    //     )
                    //     ),
                    //     // height: MediaQuery.of(context).size.height / 4,
                    //     // width: MediaQuery.of(context).size.width,
                    //     // width: ScUtil().setWidth(),
                    //     height: ScUtil().setHeight(250),
                    //     // child: Padding(
                    //     //   padding: const EdgeInsets.all(8.0),
                    //     //   child: Image.network(widget.img??widget.img,fit: BoxFit.contain,),
                    //     // ),
                    //   ),
                    // ),
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(15),
                          ),
                        ),
                        // color: Color.fromRGBO(35, 107, 254, 0.8),
                        color: Colors.transparent,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          // mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                left: ScUtil().setWidth(10),
                              ),
                              child: Center(
                                child: Text(
                                  // 'Persistent Marathon Challenge',
                                  '$eventName',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: ScUtil().setSp(16),
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.5,
                                      height: 3),
                                ),
                              ),
                            ),
                            Center(
                              child: Text(
                                // 'Date: 9th Janaury 2022',
                                'Date: $eventDate',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: ScUtil().setSp(15),
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                    height: 3),
                              ),
                            ),
                            Center(
                              child: Text(
                                // 'Location: $eventLocation',
                                'Location: ${widget.userEnrolledMap['location']}',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: ScUtil().setSp(15),
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                    height: 3),
                              ),
                            ),

                            // Row(
                            //   children: [
                            //     Spacer(flex: 3,),
                            //     FloatingActionButton(
                            //
                            //       child: Center(
                            //         child: IconButton(
                            //           onPressed: pauseValue==false?(){
                            //             startt();
                            //           }
                            //               : (){
                            //             if (mounted) {
                            //               setState(() {
                            //                 pauseValue=!pauseValue;
                            //               });
                            //
                            //               //stop the duration
                            //               timerSubscription.cancel();
                            //               timerStream = null;
                            //               pauseDur = int.parse(hoursStr) * 60 * 60 + int.parse(minutesStr)*60+int.parse(secondsStr);
                            //               print('pause dur => $pauseDur');
                            //               setState(() {
                            //                 // hoursStr = '00';
                            //                 // minutesStr = '00';
                            //                 // secondsStr = '00';
                            //                 onPauseHoursStr = hoursStr;
                            //                 onPauseMinutesStr = minutesStr;
                            //                 onPauseSecondsStr = secondsStr;
                            //                 onPauseAvailable = true;
                            //               });
                            //               //and log the time VIA LOGSTEPSAPI
                            //
                            //             }
                            //           },
                            //           icon: pauseValue?Icon(Icons.pause_circle_outline_outlined):Icon(Icons.play_circle_outline_sharp),
                            //           color: pauseValue?Colors.amber:Colors.blueAccent,
                            //           iconSize: 40,
                            //         ),
                            //       ),
                            //       backgroundColor: Colors.white,
                            //     ),
                            //
                            //     Spacer(flex: 1,),
                            //     FloatingActionButton(
                            //       backgroundColor: Colors.white,
                            //       child: Center(
                            //         child: IconButton(
                            //           onPressed: (){
                            //
                            //             if (mounted) {
                            //               setState(() {
                            //                 stopValue=true;
                            //                 pauseValue=false;
                            //               });
                            //
                            //               //stop the duration
                            //               timerSubscription.cancel();
                            //               timerStream = null;
                            //               int dur = int.parse(hoursStr) * 60 + int.parse(minutesStr);
                            //               print('stop dur => $dur');
                            //               setState(() {
                            //                 hoursStr = '00';
                            //                 minutesStr = '00';
                            //                 secondsStr = '00';
                            //                 onPauseHoursStr = '00';
                            //                 onPauseMinutesStr = '00';
                            //                 onPauseSecondsStr = '00';
                            //                 onPauseAvailable = false;
                            //                 _timer.cancel();
                            //               });
                            //               //and log the time VIA LOGSTEPSAPI
                            //
                            //             }
                            //
                            //           },
                            //           icon: Icon(Icons.stop_circle_outlined),
                            //           color: Colors.redAccent,
                            //           iconSize: 40,
                            //         ),
                            //       ),
                            //     ),
                            //     Spacer(flex: 4,),
                            //   ],
                            // ),
                            SizedBox(
                              height: ScUtil().setHeight(10),
                            ),
                            Visibility(
                              visible: widget.userEnrolledMap['event_status'] != 'stop' &&
                                  widget.userEnrolledMap['event_status'] != 'complete',
                              child: Container(
                                width: MediaQuery.of(context).size.width,

                                // width: ScUtil().setWidth(110),
                                height: ScUtil().setHeight(70),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    // Remaining Card starts
                                    Visibility(
                                      visible: widget.userEnrolledMap['event_status'] != 'stop' &&
                                          widget.userEnrolledMap['event_status'] != 'complete',
                                      child: Container(
                                        width: ScUtil().setWidth(140),
                                        height: ScUtil().setHeight(70),
                                        child: Card(
                                            child: Column(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Text(
                                              'Remaining',
                                              style: TextStyle(
                                                  color: Colors.blueAccent,
                                                  letterSpacing: 0.7,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: ScUtil().setSp(17)),
                                            ),
                                            ValueListenableBuilder(
                                              valueListenable: todaySteps,
                                              builder: (context, value, widget) {
                                                String v = value.toString();
                                                // if(value.toString().length<2){
                                                //   v= STR.kms(steps: value.toString()).toString();
                                                // }

                                                return Text(
                                                  "${totalDistance - STR.kmsWithSteps(steps: value.toString())} KM",
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    letterSpacing: 1.5,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: ScUtil().setSp(14),
                                                  ),
                                                );
                                              },
                                            ),
                                            // Text(
                                            //   // '2.03 KM',
                                            //   "${totalDistance - STR.kms()} KM",
                                            //   style: TextStyle(
                                            //       color: Colors.black,
                                            //       letterSpacing: 0.8,
                                            //       fontWeight: FontWeight.w600,
                                            //       fontSize: ScUtil().setSp(18)),
                                            // ),
                                          ],
                                        )),
                                      ),
                                    ),
                                    // Remaining Card ends
                                    // Covered Card starts

                                    Visibility(
                                      visible: widget.userEnrolledMap['event_status'] != 'stop' &&
                                          widget.userEnrolledMap['event_status'] != 'complete',
                                      child: Container(
                                        width: ScUtil().setWidth(140),
                                        height: ScUtil().setHeight(70),
                                        child: Card(
                                            child: Column(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Text(
                                              'Covered',
                                              style: TextStyle(
                                                  color: Colors.blueAccent,
                                                  letterSpacing: 0.7,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: ScUtil().setSp(17)),
                                            ),
                                            ValueListenableBuilder(
                                              valueListenable: todaySteps,
                                              builder: (context, value, widget) {
                                                String v = value.toString();
                                                // if(value.toString().length<2){
                                                //   v= STR.kms(steps: value.toString()).toString();
                                                // }

                                                return Text(
                                                  STR
                                                              .kmsWithSteps(steps: value.toString())
                                                              .toString()
                                                              .length <
                                                          4
                                                      ? "${STR.kmsWithSteps(steps: value.toString())}0 KM"
                                                      : "${STR.kmsWithSteps(steps: value.toString())} KM",
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    letterSpacing: 1.5,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: ScUtil().setSp(14),
                                                  ),
                                                );
                                              },
                                            ),
                                            // Text(
                                            //   // '7.97 KM',
                                            //   // "${STR.kms()} KM",
                                            //   "${STR.kms()} KM",
                                            //   style: TextStyle(
                                            //       color: Colors.black,
                                            //       letterSpacing: 0.8,
                                            //       fontWeight: FontWeight.w600,
                                            //       fontSize: ScUtil().setSp(18)),
                                            // )
                                          ],
                                        )),
                                      ),
                                    )
                                    // Covered Card ends
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              height: ScUtil().setHeight(10),
                            ),
                          ],
                        ),
                      ),
                    ),

                    /// Duration Card starts
                    // Container(
                    //   // height: 80,
                    //   // width: 120,
                    //   width: ScUtil().setWidth(300),
                    //   height: ScUtil().setHeight(70),
                    //   child: Card(
                    //       child: Column(
                    //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    //         children: [
                    //           Text(
                    //             'Duration',
                    //             style: TextStyle(
                    //               color: Colors.blueAccent,
                    //               letterSpacing: 1.5,
                    //               fontWeight: FontWeight.w600,
                    //               fontSize: ScUtil().setSp(14),
                    //             ),
                    //           ),
                    //           Text(
                    //             "$hoursStr:$minutesStr:$secondsStr",
                    //             style: TextStyle(
                    //                 color: Colors.black,
                    //                 letterSpacing: 1.5,
                    //                 fontWeight: FontWeight.w600,
                    //                 fontSize: ScUtil().setSp(14)),
                    //           )
                    //         ],
                    //       )),
                    // ),
                    // Duration Card ends
                    SizedBox(
                      height: ScUtil().setHeight(20),
                    ),
                    (widget.userEnrolledMap['event_status'] != 'stop' &&
                            widget.userEnrolledMap['event_status'] != 'complete')
                        ? Column(
                            children: [
                              // ValueListenableBuilder(
                              //   valueListenable: todaySteps,
                              //   builder: (context, value, widget) {
                              //     String v = value.toString();
                              //     if(value.toString().length<2){
                              //       v= '0'+value.toString();
                              //     }
                              //     return  buildTimeCard(time: v.toString(), header:'STEPS',);
                              //   },
                              // ),
                              SizedBox(
                                height: ScUtil().setHeight(20),
                              ),
                              // pauseValue==true && widget.pauseOrResume!=true?Row(
                              pauseValue != true && widget.pauseOrResume != true
                                  ? Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                      ValueListenableBuilder(
                                        valueListenable: apiHoursStr,
                                        builder: (context, value, widget) {
                                          String v = value.toString();
                                          if (value.toString().length < 2) {
                                            v = '0' + value.toString();
                                          }
                                          return buildTimeCard(
                                            time: v.toString(),
                                            header: 'HOURS',
                                          );
                                        },
                                      ),

                                      SizedBox(
                                        width: ScUtil().setWidth(15),
                                      ),

                                      ValueListenableBuilder(
                                        valueListenable: apiMinutesStr,
                                        builder: (context, value, widget) {
                                          String v = value.toString();
                                          if (value.toString().length < 2) {
                                            v = '0' + value.toString();
                                          }

                                          return buildTimeCard(
                                            time: v.toString(),
                                            header: 'MINUTES',
                                          );
                                        },
                                      ),

                                      SizedBox(
                                        width: ScUtil().setWidth(15),
                                      ),
                                      ValueListenableBuilder(
                                        valueListenable: apiSecondsStr,
                                        builder: (context, value, widget) {
                                          String v = value.toString();
                                          if (value.toString().length < 2) {
                                            v = '0' + value.toString();
                                          }

                                          return buildTimeCard(
                                            time: v.toString(),
                                            header: 'SECONDS',
                                          );
                                        },
                                      ),

                                      // buildTimeCard(time: minutesStr.toString(), header:'MINUTES'),
                                      // SizedBox(width: ScUtil().setWidth(15),),
                                      // buildTimeCard(time: secondsStr.toString(), header:'SECONDS'),
                                    ])
                                  : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                      ValueListenableBuilder(
                                        valueListenable: hoursStr,
                                        builder: (context, value, widget) {
                                          String v = value.toString();
                                          if (value.toString().length < 2) {
                                            v = '0' + value.toString();
                                          }
                                          return buildTimeCard(
                                            time: v.toString(),
                                            header: 'HOURS',
                                          );
                                        },
                                      ),

                                      SizedBox(
                                        width: ScUtil().setWidth(15),
                                      ),

                                      ValueListenableBuilder(
                                        valueListenable: minutesStr,
                                        builder: (context, value, widget) {
                                          String v = value.toString();
                                          if (value.toString().length < 2) {
                                            v = '0' + value.toString();
                                          }

                                          return buildTimeCard(
                                            time: v.toString(),
                                            header: 'MINUTES',
                                          );
                                        },
                                      ),

                                      SizedBox(
                                        width: ScUtil().setWidth(15),
                                      ),
                                      ValueListenableBuilder(
                                        valueListenable: secondsStr,
                                        builder: (context, value, widget) {
                                          String v = value.toString();
                                          if (value.toString().length < 2) {
                                            v = '0' + value.toString();
                                          }

                                          return buildTimeCard(
                                            time: v.toString(),
                                            header: 'SECONDS',
                                          );
                                        },
                                      ),

                                      // buildTimeCard(time: minutesStr.toString(), header:'MINUTES'),
                                      // SizedBox(width: ScUtil().setWidth(15),),
                                      // buildTimeCard(time: secondsStr.toString(), header:'SECONDS'),
                                    ]),
                              SizedBox(
                                height: ScUtil().setHeight(25),
                              ),
                              Row(
                                children: [
                                  Spacer(
                                    flex: 3,
                                  ),
                                  Container(
                                      decoration: BoxDecoration(
                                          // Add from this line
                                          color: Colors.white,
                                          // color: Color.fromRGBO(35, 107, 254, 0.6).withOpacity(0.85),
                                          borderRadius: BorderRadius.circular(16),
                                          boxShadow: [
                                            BoxShadow(
                                                offset: Offset(10, 10),
                                                color: Colors.black38,
                                                blurRadius: 15),
                                            BoxShadow(
                                                offset: Offset(-10, -10),
                                                color: Color.fromRGBO(35, 107, 254, 0.6)
                                                    .withOpacity(0.3),
                                                blurRadius: 15)
                                          ]),
                                      // height: 80,
                                      // width: 120,
                                      width: ScUtil().setWidth(100),
                                      height: ScUtil().setHeight(55),
                                      child: IconButton(
                                        onPressed: pauseValue == false
                                            ? () async {
                                                await checkPermission(event_status: 'resume');
                                                var status =
                                                    await Permission.activityRecognition.status;
                                                if (status.isGranted) {
                                                  if (mounted) {
                                                    setState(() {
                                                      pauseValue = !pauseValue;
                                                    });
                                                  }
                                                }
                                                // STR.startt(
                                                //     'resume',
                                                //     widget.eventDetailList[widget.indexed]
                                                //         ['event_id']);
                                                // //steps counting start(pedometer will start listening)
                                                // STR.initPlatformState();
                                              }
                                            : () {
                                                if (mounted) {
                                                  setState(() {
                                                    pauseValue = !pauseValue;
                                                  });
                                                  setState(() {
                                                    apiHoursStr = hoursStr;
                                                    apiMinutesStr = minutesStr;
                                                    apiSecondsStr = secondsStr;
                                                    onPauseAvailable = true;
                                                  });
                                                  //stop the duration
                                                  STR.timerSubscription.cancel();
                                                  STR.timerStream = null;
                                                  //we stop the step walker or stop the pedeometer
                                                  STR.stopListening();
                                                  pauseDur = int.parse(hoursStr.value.toString()) *
                                                          60 *
                                                          60 +
                                                      int.parse(minutesStr.value.toString()) * 60 +
                                                      int.parse(secondsStr.value.toString());
                                                  // pauseDur = pauseDur+storedDur;
                                                  print('pause dur => $pauseDur');
                                                  setState(() {
                                                    onPauseHoursStr = hoursStr;
                                                    onPauseMinutesStr = minutesStr;
                                                    onPauseSecondsStr = secondsStr;
                                                    onPauseAvailable = true;
                                                  });
                                                }

                                                ///todo: call the api with status pause and save data in sp

                                                DateFormat dateFormat =
                                                    DateFormat("yyyy-MM-dd HH:mm:ss");
                                                STR.saveStepsAndValidateEvent(
                                                    pauseDur,
                                                    'pause',
                                                    widget.eventDetailList[widget.indexed]
                                                        ['event_id']);
                                                // String e_timing =
                                                //     STR.getProgresstimes(
                                                //         hoursStr.value
                                                //             .toString(),
                                                //         minutesStr.value
                                                //             .toString(),
                                                //         secondsStr.value
                                                //             .toString());
                                                // trackProgressApi(
                                                //     event_id: widget
                                                //             .eventDetailList[widget.indexed]
                                                //         ['event_id'],
                                                //     ihl_user_id:
                                                //         event_iHL_User_Id,
                                                //     steps: todaySteps.value
                                                //         .toString(),
                                                //     distance_covered:
                                                //         STR.kms().toString(),
                                                //     event_status: 'pause',
                                                //     start_time: '',
                                                //     progress_time: e_timing);
                                              },
                                        icon: pauseValue
                                            ? Icon(Icons.pause_circle_filled_outlined)
                                            : Icon(Icons.play_circle_outline_sharp),
                                        color: pauseValue ? Colors.amber : Colors.blueAccent,
                                        iconSize: 45,
                                      )),
                                  Spacer(
                                    flex: 3,
                                  ),
                                  Visibility(
                                    visible: stopValue == false,
                                    child: Container(
                                        decoration: BoxDecoration(
                                            // Add from this line
                                            color: Colors.white,
                                            // color: Color.fromRGBO(35, 107, 254, 0.6).withOpacity(0.85),
                                            borderRadius: BorderRadius.circular(16),
                                            boxShadow: [
                                              BoxShadow(
                                                  offset: Offset(10, 10),
                                                  color: Colors.black38,
                                                  blurRadius: 15),
                                              BoxShadow(
                                                  offset: Offset(-10, -10),
                                                  color: Color.fromRGBO(35, 107, 254, 0.6)
                                                      .withOpacity(0.3),
                                                  blurRadius: 15)
                                            ]),
                                        width: ScUtil().setWidth(100),
                                        height: ScUtil().setHeight(55),
                                        child: IconButton(
                                          onPressed: () {
                                            AwesomeDialog(
                                                context: context,
                                                animType: AnimType.TOPSLIDE,
                                                headerAnimationLoop: true,
                                                dialogType: DialogType.question,
                                                dismissOnTouchOutside: true,
                                                title: 'wanna stop!',
                                                desc: 'this will stop your marathon tracking',
                                                btnOkOnPress: () async {
                                                  await stopStreamOfWatchAndSteps();
                                                  showFromSharedPref = false;
                                                  Get.off(LandingPage());
                                                  // Get.back();
                                                },
                                                btnCancelOnPress: () {
                                                  showFromSharedPref = false;
                                                  Get.off(LandingPage());
                                                },
                                                btnCancelText: 'Go Back',
                                                btnOkText: 'Continue',
                                                btnCancelColor: Colors.green,
                                                btnOkColor: Colors.red,
                                                // btnOkIcon: Icons.check_circle,
                                                // btnCancelIcon: Icons.check_circle,
                                                onDismissCallback: (_) {
                                                  debugPrint('Dialog Dissmiss from callback');
                                                }).show();
                                            // alertBox('you are not completed the marathon', Colors.blueAccent);
                                            // stopStreamOfWatchAndSteps();
                                          },
                                          icon: Icon(Icons.stop_circle_outlined),
                                          color: Colors.redAccent,
                                          iconSize: 45,
                                        )),
                                  ),
                                  Spacer(
                                    flex: 4,
                                  ),
                                ],
                              ),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      Column(
                                        children: [
                                          Text(
                                            widget.userEnrolledMap['event_status'] != 'stop'
                                                ? 'Congratulations !'
                                                : '  Thank you !!!',
                                            style: TextStyle(
                                                fontSize: ScUtil().setSp(23),
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Container(
                                              width: ScUtil().setWidth(190),
                                              child: Text(
                                                widget.userEnrolledMap['event_status'] != 'stop'
                                                    ? 'You have successfully completed !'
                                                    : '      You did Great.',
                                                style: TextStyle(
                                                  fontSize: ScUtil().setSp(18),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              )),
                                        ],
                                      ),
                                      Container(
                                        // color: Colors.red,
                                        child: Lottie.network(
                                          widget.userEnrolledMap['event_status'] != 'stop'
                                              ? "https://assets4.lottiefiles.com/packages/lf20_k4rdnrh1.json"
                                              : "https://assets4.lottiefiles.com/packages/lf20_yh1grvx2.json",
                                          height: ScUtil().setHeight(80),
                                          width: ScUtil().setWidth(110),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: ScUtil().setHeight(10),
                              ),
                              Visibility(
                                visible: widget.userEnrolledMap['event_status'] == 'stop' ||
                                    widget.userEnrolledMap['event_status'] == 'complete',
                                child: Container(
                                  margin: EdgeInsets.only(left: 8, right: 8),
                                  width: double.infinity,
                                  // width: ScUtil().setWidth(300),
                                  height: ScUtil().setHeight(240),
                                  child: Card(
                                      child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      SizedBox(
                                        height: ScUtil().setHeight(5),
                                      ),
                                      Text(
                                        'Total Distance',
                                        style: TextStyle(
                                            color: Colors.blueAccent,
                                            letterSpacing: 0.7,
                                            fontWeight: FontWeight.w600,
                                            fontSize: ScUtil().setSp(17)),
                                      ),
                                      Text(
                                        // '7.97 KM',
                                        "$totalDistance KM",
                                        style: TextStyle(
                                          color: Colors.black,
                                          letterSpacing: 0.8,
                                          fontWeight: FontWeight.w600,
                                          fontSize: ScUtil().setSp(18),
                                        ),
                                      ),
                                      Divider(
                                        color: Colors.grey.shade300,
                                        indent: 40,
                                        endIndent: 40,
                                        thickness: 1,
                                      ),
                                      Text(
                                        'Distance Covered',
                                        style: TextStyle(
                                            color: Colors.blueAccent,
                                            letterSpacing: 0.7,
                                            fontWeight: FontWeight.w600,
                                            fontSize: ScUtil().setSp(17)),
                                      ),
                                      Text(
                                        // '7.97 KM',
                                        // widget.userEnrolledMap['using_ihl_app'] ==
                                        //         'IHL Care'
                                        //     ? "${STR.kms()} KM"
                                        //     :
                                        "${widget.userEnrolledMap['distance_covered']} KM",
                                        style: TextStyle(
                                            color: Colors.black,
                                            letterSpacing: 0.8,
                                            fontWeight: FontWeight.w600,
                                            fontSize: ScUtil().setSp(18)),
                                      ),
                                      Divider(
                                        color: Colors.grey.shade300,
                                        indent: 40,
                                        endIndent: 40,
                                        thickness: 1,
                                      ),
                                      Text(
                                        'Time Taken',
                                        style: TextStyle(
                                            color: Colors.blueAccent,
                                            letterSpacing: 0.7,
                                            fontWeight: FontWeight.w600,
                                            fontSize: ScUtil().setSp(17)),
                                      ),
                                      RichText(
                                        text: TextSpan(
                                            style: TextStyle(
                                                color: Colors.black,
                                                letterSpacing: 0.8,
                                                fontWeight: FontWeight.bold,
                                                fontSize: ScUtil().setSp(18)),
                                            children: [
                                              TextSpan(
                                                text:
                                                    // widget.userEnrolledMap[
                                                    //             'using_ihl_app'] ==
                                                    //         'IHL Care'
                                                    //     ? hoursStr.value
                                                    //                 .toString()
                                                    //                 .length >
                                                    //             1
                                                    //         ? "${hoursStr.value}:"
                                                    //         : '0${hoursStr.value}:'
                                                    //
                                                    //     :
                                                    apiHoursStr.value.toString().length > 1
                                                        ? "${apiHoursStr.value}:"
                                                        : "0${apiHoursStr.value}:",
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    letterSpacing: 0.8,
                                                    fontWeight: FontWeight.w900,
                                                    fontSize: ScUtil().setSp(18)),
                                              ),
                                              TextSpan(
                                                text:
                                                    // widget.userEnrolledMap[
                                                    //         'using_ihl_app'] ==
                                                    //     'IHL Care'
                                                    // ? minutesStr.value
                                                    //             .toString()
                                                    //             .length >
                                                    //         1
                                                    //     ? "${minutesStr.value}:"
                                                    //     : '0${minutesStr.value}:'
                                                    // :
                                                    apiMinutesStr.value.toString().length > 1
                                                        ? "${apiMinutesStr.value}:"
                                                        : "0${apiMinutesStr.value}:",
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    letterSpacing: 0.8,
                                                    fontWeight: FontWeight.w900,
                                                    fontSize: ScUtil().setSp(18)),
                                              ),
                                              TextSpan(
                                                text:
                                                    // widget.userEnrolledMap[
                                                    //             'using_ihl_app'] ==
                                                    //         'IHL Care'
                                                    //     ? secondsStr.value
                                                    //                 .toString()
                                                    //                 .length >
                                                    //             1
                                                    //         ? "${secondsStr.value}"
                                                    //         : '0${secondsStr.value}'
                                                    //     :
                                                    apiSecondsStr.value.toString().length > 1
                                                        ? "${apiSecondsStr.value}"
                                                        : "0${apiSecondsStr.value}",
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    letterSpacing: 0.8,
                                                    fontWeight: FontWeight.w900,
                                                    fontSize: ScUtil().setSp(18)),
                                              ),
                                            ]),
                                      ),
                                      SizedBox(
                                        height: ScUtil().setHeight(5),
                                      ),
                                      // Text(
                                      //   // '7.97 KM',
                                      //   "${hoursStr.value}:${minutesStr.value}:${secondsStr.value}",
                                      //   style: TextStyle(
                                      //       color: Colors.black,
                                      //       letterSpacing: 0.8,
                                      //       fontWeight: FontWeight.w600,
                                      //       fontSize: ScUtil().setSp(18)),
                                      // ),
                                    ],
                                  )),
                                ),
                              ),
                            ],
                          )
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      // return SafeArea(
      //   child: Scaffold(
      //     body: SingleChildScrollView(
      //       child: Padding(
      //         padding: const EdgeInsets.all(5.0),
      //         child: Container(
      //           // width: ScUtil().setWidth(),
      //           width: MediaQuery.of(context).size.width,
      //           // height: MediaQuery.of(context).size.height / 1,
      //           height: ScUtil().setHeight(600),
      //           decoration: BoxDecoration(
      //             // color: Colors.tealAccent,
      //             color: Color.fromRGBO(35, 107, 254, 0.6),
      //             borderRadius: BorderRadius.circular(20),
      //           ),
      //           child: Column(
      //             crossAxisAlignment: CrossAxisAlignment.center,
      //             mainAxisAlignment: MainAxisAlignment.start,
      //             children: [
      //               Center(
      //                 child: Row(
      //                   crossAxisAlignment: CrossAxisAlignment.end,
      //                   mainAxisAlignment: MainAxisAlignment.start,
      //                   children: [
      //                     TextButton(
      //                         onPressed: () {
      //                           Get.back();
      //                         },
      //                         child: Icon(
      //                           Icons.arrow_back_ios,
      //                           color: Colors.white,
      //                         )),
      //                     Text(
      //                       '${widget.name}',
      //                       style: TextStyle(
      //                           color: Colors.white,
      //                           fontSize: ScUtil().setSp(16),
      //                           fontWeight: FontWeight.w600,
      //                           letterSpacing: 0.7,
      //                           height: 4
      //                       ),
      //                     ),
      //                   ],
      //                 ),
      //               ),
      //               SizedBox(
      //                 height: ScUtil().setHeight(15),
      //               ),
      //               // Padding(
      //               //   padding: const EdgeInsets.all(8.0),
      //               //   child: Container(
      //               //     decoration: BoxDecoration(
      //               //         borderRadius: BorderRadius.circular(20),
      //               //     image: DecorationImage(
      //               //       image: NetworkImage(widget.img??widget.img,),
      //               //     )
      //               //     ),
      //               //     // height: MediaQuery.of(context).size.height / 4,
      //               //     // width: MediaQuery.of(context).size.width,
      //               //     // width: ScUtil().setWidth(),
      //               //     height: ScUtil().setHeight(250),
      //               //     // child: Padding(
      //               //     //   padding: const EdgeInsets.all(8.0),
      //               //     //   child: Image.network(widget.img??widget.img,fit: BoxFit.contain,),
      //               //     // ),
      //               //   ),
      //               // ),
      //               Padding(
      //                 padding: const EdgeInsets.all(4.0),
      //                 child: Card(
      //                   shape: RoundedRectangleBorder(
      //                     borderRadius: BorderRadius.all(
      //                       Radius.circular(15),
      //                     ),
      //                   ),
      //                   // color: Color.fromRGBO(35, 107, 254, 0.8),
      //                   color: Colors.transparent,
      //                   child: Column(
      //                     crossAxisAlignment: CrossAxisAlignment.center,
      //                     // mainAxisAlignment: MainAxisAlignment.center,
      //                     children: [
      //
      //                       Center(
      //                         child: Text(
      //                           // 'Persistent Marathon Challenge',
      //                           '$eventName',
      //                           style: TextStyle(
      //                               color: Colors.white,
      //                               fontSize: ScUtil().setSp(16),
      //                               fontWeight: FontWeight.w600,
      //                               letterSpacing: 1.0,
      //                               height: 3),
      //                         ),
      //                       ),
      //                       Center(
      //                         child: Text(
      //                           // 'Date: 9th Janaury 2022',
      //                           'Date: $eventDate',
      //                           style: TextStyle(
      //                               color: Colors.white,
      //                               fontSize: ScUtil().setSp(14),
      //                               fontWeight: FontWeight.w600,
      //                               letterSpacing: 0.5,
      //                               height: 3),
      //                         ),
      //                       ),
      //                       Center(
      //                         child: Text(
      //                           // 'Location: Near XYZ ',
      //                           'Location: $eventLocation',
      //                           style: TextStyle(
      //                               color: Colors.white,
      //                               fontSize: ScUtil().setSp(14),
      //                               fontWeight: FontWeight.w600,
      //                               letterSpacing: 0.5,
      //                               height: 3),
      //                         ),
      //                       ),
      //
      //                       // Row(
      //                       //   children: [
      //                       //     Spacer(flex: 3,),
      //                       //     FloatingActionButton(
      //                       //
      //                       //       child: Center(
      //                       //         child: IconButton(
      //                       //           onPressed: pauseValue==false?(){
      //                       //             startt();
      //                       //           }
      //                       //               : (){
      //                       //             if (mounted) {
      //                       //               setState(() {
      //                       //                 pauseValue=!pauseValue;
      //                       //               });
      //                       //
      //                       //               //stop the duration
      //                       //               timerSubscription.cancel();
      //                       //               timerStream = null;
      //                       //               pauseDur = int.parse(hoursStr) * 60 * 60 + int.parse(minutesStr)*60+int.parse(secondsStr);
      //                       //               print('pause dur => $pauseDur');
      //                       //               setState(() {
      //                       //                 // hoursStr = '00';
      //                       //                 // minutesStr = '00';
      //                       //                 // secondsStr = '00';
      //                       //                 onPauseHoursStr = hoursStr;
      //                       //                 onPauseMinutesStr = minutesStr;
      //                       //                 onPauseSecondsStr = secondsStr;
      //                       //                 onPauseAvailable = true;
      //                       //               });
      //                       //               //and log the time VIA LOGSTEPSAPI
      //                       //
      //                       //             }
      //                       //           },
      //                       //           icon: pauseValue?Icon(Icons.pause_circle_outline_outlined):Icon(Icons.play_circle_outline_sharp),
      //                       //           color: pauseValue?Colors.amber:Colors.blueAccent,
      //                       //           iconSize: 40,
      //                       //         ),
      //                       //       ),
      //                       //       backgroundColor: Colors.white,
      //                       //     ),
      //                       //
      //                       //     Spacer(flex: 1,),
      //                       //     FloatingActionButton(
      //                       //       backgroundColor: Colors.white,
      //                       //       child: Center(
      //                       //         child: IconButton(
      //                       //           onPressed: (){
      //                       //
      //                       //             if (mounted) {
      //                       //               setState(() {
      //                       //                 stopValue=true;
      //                       //                 pauseValue=false;
      //                       //               });
      //                       //
      //                       //               //stop the duration
      //                       //               timerSubscription.cancel();
      //                       //               timerStream = null;
      //                       //               int dur = int.parse(hoursStr) * 60 + int.parse(minutesStr);
      //                       //               print('stop dur => $dur');
      //                       //               setState(() {
      //                       //                 hoursStr = '00';
      //                       //                 minutesStr = '00';
      //                       //                 secondsStr = '00';
      //                       //                 onPauseHoursStr = '00';
      //                       //                 onPauseMinutesStr = '00';
      //                       //                 onPauseSecondsStr = '00';
      //                       //                 onPauseAvailable = false;
      //                       //                 _timer.cancel();
      //                       //               });
      //                       //               //and log the time VIA LOGSTEPSAPI
      //                       //
      //                       //             }
      //                       //
      //                       //           },
      //                       //           icon: Icon(Icons.stop_circle_outlined),
      //                       //           color: Colors.redAccent,
      //                       //           iconSize: 40,
      //                       //         ),
      //                       //       ),
      //                       //     ),
      //                       //     Spacer(flex: 4,),
      //                       //   ],
      //                       // ),
      //                       SizedBox(height: 8,),
      //                       Container(
      //                         width: MediaQuery.of(context).size.width,
      //
      //                         //  width: ScUtil().setWidth(110),
      //                         height: ScUtil().setHeight(70),
      //                         child: Row(
      //                           crossAxisAlignment: CrossAxisAlignment.center,
      //                           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      //                           children: [
      //                             // Remaining Card starts
      //                             Container(
      //                               width: ScUtil().setWidth(140),
      //                               height: ScUtil().setHeight(70),
      //                               child: Card(
      //                                   child: Column(
      //                                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      //                                     children: [
      //                                       Text(
      //                                         'Remaining',
      //                                         style: TextStyle(
      //                                             color: Colors.blueAccent,
      //                                             letterSpacing: 0.7,
      //                                             fontWeight: FontWeight.w600,
      //                                             fontSize: ScUtil().setSp(17)),
      //                                       ),
      //                                       Text(
      //                                         '2.03 KM',
      //                                         style: TextStyle(
      //                                             color: Colors.black,
      //                                             letterSpacing: 0.8,
      //                                             fontWeight: FontWeight.w600,
      //                                             fontSize: ScUtil().setSp(18)),
      //                                       )
      //                                     ],
      //                                   )),
      //                             ),
      //                             // Remaining Card ends
      //                             // Covered Card starts
      //
      //                             Container(
      //                               width: ScUtil().setWidth(140),
      //                               height: ScUtil().setHeight(70),
      //                               child: Card(
      //                                   child: Column(
      //                                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      //                                     children: [
      //                                       Text(
      //                                         'Covered',
      //                                         style: TextStyle(
      //                                             color: Colors.blueAccent,
      //                                             letterSpacing: 0.7,
      //                                             fontWeight: FontWeight.w600,
      //                                             fontSize: ScUtil().setSp(17)),
      //                                       ),
      //                                       Text(
      //                                         '7.97 KM',
      //                                         style: TextStyle(
      //                                             color: Colors.black,
      //                                             letterSpacing: 0.8,
      //                                             fontWeight: FontWeight.w600,
      //                                             fontSize: ScUtil().setSp(18)),
      //                                       )
      //                                     ],
      //                                   )),
      //                             )
      //                             // Covered Card ends
      //                           ],
      //                         ),
      //                       ),
      //                       SizedBox(height: 9,),
      //
      //                     ],
      //                   ),
      //                 ),
      //               ),
      //
      //               /// Duration Card starts
      //               // Container(
      //               //   // height: 80,
      //               //   // width: 120,
      //               //   width: ScUtil().setWidth(300),
      //               //   height: ScUtil().setHeight(70),
      //               //   child: Card(
      //               //       child: Column(
      //               //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      //               //         children: [
      //               //           Text(
      //               //             'Duration',
      //               //             style: TextStyle(
      //               //               color: Colors.blueAccent,
      //               //               letterSpacing: 1.5,
      //               //               fontWeight: FontWeight.w600,
      //               //               fontSize: ScUtil().setSp(14),
      //               //             ),
      //               //           ),
      //               //           Text(
      //               //             "$hoursStr:$minutesStr:$secondsStr",
      //               //             style: TextStyle(
      //               //                 color: Colors.black,
      //               //                 letterSpacing: 1.5,
      //               //                 fontWeight: FontWeight.w600,
      //               //                 fontSize: ScUtil().setSp(14)),
      //               //           )
      //               //         ],
      //               //       )),
      //               // ),
      //               // Duration Card ends
      //               SizedBox(height: ScUtil().setHeight(70),),
      //                Row(
      //             mainAxisAlignment: MainAxisAlignment.center,
      //             children: [
      //               buildTimeCard(time: hoursStr, header:'HOURS',),
      //               SizedBox(width: ScUtil().setWidth(15),),
      //               buildTimeCard(time: minutesStr, header:'MINUTES'),
      //               SizedBox(width: ScUtil().setWidth(15),),
      //               buildTimeCard(time: secondsStr, header:'SECONDS'),
      //             ]
      //         ),
      //               SizedBox(height: ScUtil().setHeight(15),),
      //               Row(
      //                 children: [
      //                   Spacer(flex: 3,),
      //                   Container(
      //                       decoration: BoxDecoration(    // Add from this line
      //                           color: Colors.white,
      //                           // color: Color.fromRGBO(35, 107, 254, 0.6).withOpacity(0.85),
      //                           borderRadius: BorderRadius.circular(16),
      //                           boxShadow: [
      //                             BoxShadow(
      //                                 offset: Offset(10, 10),
      //                                 color: Colors.black38,
      //                                 blurRadius: 15),
      //                             BoxShadow(
      //                                 offset: Offset(-10, -10),
      //                                 color: Color.fromRGBO(35, 107, 254, 0.6).withOpacity(0.3),
      //                                 blurRadius: 15)
      //                           ]),
      //                       // height: 80,
      //                       // width: 120,
      //                       width: ScUtil().setWidth(100),
      //                       height: ScUtil().setHeight(55),
      //                       child: IconButton(
      //                         onPressed: pauseValue==false?(){
      //                           startt();
      //                         }
      //                             : (){
      //                           if (mounted) {
      //                             setState(() {
      //                               pauseValue=!pauseValue;
      //                             });
      //
      //                             //stop the duration
      //                             timerSubscription.cancel();
      //                             timerStream = null;
      //                             pauseDur = int.parse(hoursStr) * 60 * 60 + int.parse(minutesStr)*60+int.parse(secondsStr);
      //                             print('pause dur => $pauseDur');
      //                             setState(() {
      //                               // hoursStr = '00';
      //                               // minutesStr = '00';
      //                               // secondsStr = '00';
      //                               onPauseHoursStr = hoursStr;
      //                               onPauseMinutesStr = minutesStr;
      //                               onPauseSecondsStr = secondsStr;
      //                               onPauseAvailable = true;
      //                             });
      //                             //and log the time VIA LOGSTEPSAPI
      //
      //                           }
      //                         },
      //                         icon: pauseValue?Icon(Icons.pause_circle_filled_outlined):Icon(Icons.play_circle_outline_sharp),
      //                         color: pauseValue?Colors.amber:Colors.blueAccent,
      //                         iconSize: 45,
      //                       )
      //                   ),
      //
      //                   Spacer(flex: 3,),
      //                   Visibility(
      //                     visible: stopValue==false,
      //                     child: Container(
      //                         decoration: BoxDecoration(    // Add from this line
      //                             color: Colors.white,
      //                             // color: Color.fromRGBO(35, 107, 254, 0.6).withOpacity(0.85),
      //                             borderRadius: BorderRadius.circular(16),
      //                             boxShadow: [
      //                               BoxShadow(
      //                                   offset: Offset(10, 10),
      //                                   color: Colors.black38,
      //                                   blurRadius: 15),
      //                               BoxShadow(
      //                                   offset: Offset(-10, -10),
      //                                   color: Color.fromRGBO(35, 107, 254, 0.6).withOpacity(0.3),
      //                                   blurRadius: 15)
      //                             ]),
      //                         width: ScUtil().setWidth(100),
      //                         height: ScUtil().setHeight(55),
      //                         child: IconButton(
      //                           onPressed: (){
      //                             if (mounted) {
      //                               setState(() {
      //                                 stopValue=true;
      //                                 pauseValue=false;
      //                               });
      //
      //                               //stop the duration
      //                               timerSubscription.cancel();
      //                               timerStream = null;
      //                               int dur = int.parse(hoursStr) * 60 + int.parse(minutesStr);
      //                               print('stop dur => $dur');
      //                               setState(() {
      //                                 hoursStr = '00';
      //                                 minutesStr = '00';
      //                                 secondsStr = '00';
      //                                 onPauseHoursStr = '00';
      //                                 onPauseMinutesStr = '00';
      //                                 onPauseSecondsStr = '00';
      //                                 onPauseAvailable = false;
      //                                 _timer.cancel();
      //                               });
      //                               //and log the time VIA LOGSTEPSAPI
      //
      //                             }
      //
      //                           },
      //                           icon: Icon(Icons.stop_circle_outlined),
      //                           color: Colors.redAccent,
      //                           iconSize: 45,
      //                         )
      //                     ),
      //                   ),
      //                   Spacer(flex: 4,),
      //                 ],
      //               ),
      //             ],
      //           ),
      //         ),
      //       ),
      //     ),
      //   ),
      // );
    }
  }

  stopStreamOfWatchAndSteps() async {
    if (mounted) {
      setState(() {
        stopValue = true;
        pauseValue = false;
      });

      //stop the duration
      STR.timerSubscription.cancel();
      STR.timerStream = null;

      ///we stop the pedeometer or stop the walker
      STR.stopListening();

      ///todo: call the api with status pause
      DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
      // String e_timing = dateFormat.format(DateTime.now());
      String e_timing = await STR.getProgresstimes(
          hoursStr.value.toString(), minutesStr.value.toString(), secondsStr.value.toString());

      trackProgressApi(
          event_id: widget.eventDetailList[widget.indexed]['event_id'],
          ihl_user_id: event_iHL_User_Id,
          steps: todaySteps.value.toString(),
          distance_covered: STR.kms().toString(),
          event_status: 'stop',
          start_time: '',
          progress_time: e_timing);
      // int dur = int.parse(hoursStr) * 60 + int.parse(minutesStr);
      // print('stop dur => $dur');
      // setState(() {
      //   hoursStr.value = 00;
      //   minutesStr.value = 00;
      //   secondsStr.value = 00;
      //   onPauseHoursStr.value = 00;
      //   onPauseMinutesStr.value = 00;
      //   onPauseSecondsStr.value = 00;
      //   onPauseAvailable = false;
      //   // _timer.cancel();
      // });
    }
    var prefs = await SharedPreferences.getInstance();
    prefs.setString('event_seconds', '0');
    prefs.setString('event_distance', '0');
    prefs.setString('event_steps', '0');
    prefs.setString('event_status', '');
    isCalled = false;
  }

  Widget buildTimeCard({String time, String header}) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
            child: Text(
              time.toString(),
              style: TextStyle(
                  color: Colors.black,
                  letterSpacing: 1.0,
                  fontWeight: FontWeight.w600,
                  fontSize: ScUtil().setSp(50)),
            ),

            // child: Text(
            //   time,
            //   style: TextStyle(
            //     color: Colors.black,
            //     letterSpacing: 1.0,
            //     fontWeight: FontWeight.w600,
            //     fontSize: ScUtil().setSp(50)),
            //   // style: TextStyle(fontWeight: FontWeight.bold,
            //   //   color: Colors.black,fontSize: 50),
            //
            // ),
          ),
          SizedBox(
            height: ScUtil().setHeight(15),
          ),
          Text(header, style: TextStyle(color: Colors.black)),
        ],
      );
  Stream<int> stopWatchStream() {
    StreamController<int> streamController;
    Timer timer;
    Duration timerInterval = Duration(seconds: 1);
    int counter = 0;

    void stopTimer() {
      if (timer != null) {
        timer.cancel();
        timer = null;
        counter = 0;
        streamController.close();
      }
    }

    void tick(_) {
      counter++;
      // counter = counter+59;
      streamController.add(counter);
      if (!flag) {
        stopTimer();
      }
    }

    void startTimer() {
      timer = Timer.periodic(timerInterval, tick);
    }

    streamController = StreamController<int>(
      onListen: startTimer,
      onCancel: stopTimer,
      onResume: startTimer,
      onPause: stopTimer,
    );

    return streamController.stream;
  }

  int _start = 60;
  var _timer;

  ///screenShot upload
  FilePickerResult result;
  PlatformFile file;
  sheetForSelectingReport(BuildContext context) {
    // ignore: missing_return
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
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
                children: [
                  ListTile(
                    title: Text('Select Report From Storage'),
                    leading: Icon(Icons.image),
                    onTap: () {
                      _openFileExplorer();
                      Navigator.of(context).pop();
                    },
                  ),
                  ListTile(
                    title: Text('Capture Report From Camera'),
                    leading: Icon(Icons.camera_alt_outlined),
                    onTap: () async {
                      await _imgFromCamera();
                      // Navigator.of(context).pop();
                    },
                  ),
                  SizedBox(height: 30),
                ],
              ),
            );
          },
        );
      },
    );
  }

  ///capture report from camera
  bool isImageSelectedFromCamera = false;

  CroppedFile croppedFile;
  File _image;
  final picker = ImagePicker();
  _imgFromCamera() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);
    _image = new File(pickedFile.path);
    croppedFile = await ImageCropper().cropImage(
        sourcePath: _image.path,
        aspectRatio: CropAspectRatio(ratioX: 12, ratioY: 16),
        maxWidth: 512,
        maxHeight: 512,
        compressFormat: ImageCompressFormat.png,
        compressQuality: 60,
        uiSettings: [
          AndroidUiSettings(
            lockAspectRatio: false,
            activeControlsWidgetColor: AppColors.primaryAccentColor,
            toolbarTitle: 'Crop the Image',
            toolbarColor: Color(0xFF19a9e5),
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
          ),
          IOSUiSettings(title: 'Crop the Image', aspectRatioLockEnabled: true)
        ]);
    Navigator.of(context).pop();
    if (this.mounted) {
      SharedPreferences prefs1 = await SharedPreferences.getInstance();
      var iHLUserId = prefs1.getString("ihlUserId");
      // setState(() {
      //   List<int> imageBytes = croppedFile.readAsBytesSync();
      //   var im = croppedFile.path;
      //   isImageSelectedFromCamera = true;
      //   ///instead of image selected write here the older variable file selected = true, okay and than remove this file
      //   // fileSelected = true;
      // });
      var resp = await uploadImagesAfterEvent(iHLUserId,
          widget.eventDetailList[widget.indexed]['event_id'], croppedFile.path, 'camera');
      if (resp == true) {
        // Navigator.of(context).pop();
        Get.snackbar('Uploaded!', 'Image uploaded successfully.',
            icon: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(Icons.check_circle, color: Colors.white)),
            margin: EdgeInsets.all(20).copyWith(bottom: 40),
            backgroundColor: AppColors.primaryAccentColor,
            colorText: Colors.white,
            duration: Duration(seconds: 5),
            snackPosition: SnackPosition.BOTTOM);
      } else {
        // Navigator.of(context).pop();
        Get.snackbar(
            'Image not uploaded', 'Encountered some error while uploading. Please try again',
            icon: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(Icons.cancel_rounded, color: Colors.white)),
            margin: EdgeInsets.all(20).copyWith(bottom: 40),
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: Duration(seconds: 5),
            snackPosition: SnackPosition.BOTTOM);
      }
    }
  }

  Future<void> _openFileExplorer() async {
    result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'pdf'],
      allowMultiple: true,
    );
    // FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      SharedPreferences prefs1 = await SharedPreferences.getInstance();
      var iHLUserId = prefs1.getString("ihlUserId");
      file = result.files.first;
      print(result.files);
      print(result.files.length);
      print(file.name);
      print(file.bytes);
      print(file.size);
      print(file.extension);
      print(file.path);
      var resp = await uploadImagesAfterEvent(
          iHLUserId, widget.eventDetailList[widget.indexed]['event_id'], file.path, 'gallery',
          image_list: result.files);
      if (resp == true) {
        // Navigator.of(context).pop();
        Get.snackbar('Uploaded!', 'Image uploaded successfully.',
            icon: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(Icons.check_circle, color: Colors.white)),
            margin: EdgeInsets.all(20).copyWith(bottom: 40),
            backgroundColor: AppColors.primaryAccentColor,
            colorText: Colors.white,
            duration: Duration(seconds: 5),
            snackPosition: SnackPosition.BOTTOM);
      } else {
        Navigator.of(context).pop();
        Get.snackbar(
            'Image not uploaded', 'Encountered some error while uploading. Please try again',
            icon: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(Icons.cancel_rounded, color: Colors.white)),
            margin: EdgeInsets.all(20).copyWith(bottom: 40),
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: Duration(seconds: 5),
            snackPosition: SnackPosition.BOTTOM);
      }
    } else {
      // User canceled the picker
    }
  }
}

class STR {
  // static String value;
// static  bool pauseValue = false;
//   static  bool stopValue = false;
  ///timer stopwatch vars
  // static  bool flag = true;
  // static  bool onPauseAvailable = false;
  static Stream<int> timerStream;
  static StreamSubscription<int> timerSubscription;

  // static  var pauseDur;

  static Stream<int> stopWatchStream() {
    StreamController<int> streamController;
    Timer timer;
    Duration timerInterval = Duration(seconds: 1);
    int counter = 0;

    void stopTimer() {
      if (timer != null) {
        timer.cancel();
        timer = null;
        counter = 0;
        streamController.close();
      }
    }

    void tick(_) {
      counter++;
      // counter = counter+59;
      streamController.add(counter);
      if (!flag) {
        stopTimer();
      }
    }

    void startTimer() {
      timer = Timer.periodic(timerInterval, tick);
    }

    streamController = StreamController<int>(
      onListen: startTimer,
      onCancel: stopTimer,
      onResume: startTimer,
      onPause: stopTimer,
    );

    return streamController.stream;
  }

  static void startt(status, event_id) async {
    var prefs = await SharedPreferences.getInstance();
    var data1 = prefs.get('data');
    Map res = jsonDecode(data1);
    event_iHL_User_Id = res['User']['id'];
    timerStream = stopWatchStream();
    timerSubscription = timerStream.listen((int newTick) {
      // newTick = newTi+(pauseDur*60);
      if (onPauseAvailable) {
        hoursStr.value =
            int.parse((((newTick + pauseDur) / (60 * 60)) % 60).floor().toString().padLeft(2, '0'));
        // minutesStr = (((newTick+(int.parse(onPauseMinutesStr)*60)) / 60) % 60)
        minutesStr.value =
            int.parse((((newTick + pauseDur) / 60) % 60).floor().toString().padLeft(2, '0'));
        secondsStr.value =
            // ((newTick+int.parse(onPauseSecondsStr)) % 60).floor().toString().padLeft(2, '0');
            int.parse(((newTick + pauseDur) % 60).floor().toString().padLeft(2, '0'));
        // onPauseAvailable=false;
        if (pauseDur != null) {
          if ((newTick + pauseDur) % 5 == 0) {
            saveStepsAndValidateEvent((newTick + pauseDur), status, event_id);
          }
        } else {
          if (newTick % 5 == 0) {
            saveStepsAndValidateEvent((newTick), status, event_id);
          }
        }

        // if((newTick+pauseDur!=null?pauseDur:0)%5==0){
        //   saveStepsAndValidateEvent((newTick+pauseDur),status,event_id);
        // }
      } else {
        stopValue = false;
        hoursStr.value = int.parse(((newTick / (60 * 60)) % 60).floor().toString().padLeft(2, '0'));
        minutesStr.value = int.parse(((newTick / 60) % 60).floor().toString().padLeft(2, '0'));
        secondsStr.value = int.parse((newTick % 60).floor().toString().padLeft(2, '0'));

        if (pauseDur != null) {
          if ((newTick + pauseDur) % 5 == 0) {
            saveStepsAndValidateEvent((newTick), status, event_id);
          }
        } else {
          saveStepsAndValidateEvent((newTick), status, event_id);
        }
      }
    });

    ///todo : call the api when start also...with status start or progress whatever it is
    DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
    String e_timing = dateFormat.format(DateTime.now());
    String eStartTime;
    String eProgressTime;

    if (status == 'start') {
      if (status == 'start') {
        eStartTime = e_timing;
        eProgressTime = '';
      } else {
        eStartTime = '';
        eProgressTime = await STR.getProgresstimes(
            hoursStr.value.toString(), minutesStr.value.toString(), secondsStr.value.toString());
      }
      trackProgressApi(
          event_id: event_id,
          ihl_user_id: event_iHL_User_Id,
          steps: todaySteps.value.toString(),
          distance_covered: kms().toString(),
          event_status: status,
          start_time: eStartTime,
          progress_time: eProgressTime);
    }
  }

  //STEP1+STEP3 : SAVE THE DATA=> steps,distance_covered,stopwatch_value, + with this every time check if user completed the race.
  static getProgresstimes(hour, min, sec) {
    if (hour.length < 2) {
      hour = '0' + hour;
    }
    if (min.length < 2) {
      min = '0' + min;
    }
    if (sec.length < 2) {
      sec = '0' + sec;
    }
    return '1800-01-01 $hour:$min:$sec';
  }

  static double kmPerStep = 0.000762;
  static kmsWithSteps({steps}) {
    steps = steps.toString();
    // double toSend = _stepCountValue * kmPerStep * 100;
    if (steps != null && steps != 'null') {
      double toSend = int.parse(steps) * kmPerStep * 100;
      int clean = toSend.toInt();
      toSend = clean / 100;
      // if(toSend.toString().replaceAll('.', '').length<3){
      //   return
      // }
      return (toSend);
    }
  }

  static double kms() {
    double toSend = todaySteps.value * kmPerStep * 100;
    int clean = toSend.toInt();
    toSend = clean / 100;
    print('km covered $toSend');
    return (toSend);
  }

  static void saveStepsAndValidateEvent(seconds, event_status, event_id) async {
    String e_timing = await STR.getProgresstimes(
        hoursStr.value.toString(), minutesStr.value.toString(), secondsStr.value.toString());
    await trackProgressApi(
        event_id: event_id,
        ihl_user_id: event_iHL_User_Id,
        steps: todaySteps.value.toString(),
        distance_covered: kms().toString(),
        event_status: event_status, //'progress',
        start_time: '',
        progress_time: e_timing);

    double distance = kms();
    //this 5 will be the selected variant for the user.
    // var aa = '2021-12-18 00:15:00';
    // var x  = DateTime.parse(aa);
    // print(DateTime.now().difference(x).inMinutes>5);
    if (distance >= totalDistance) {
      // setState(() {
      stopValue = true;
      pauseValue = false;
      // });

      //stop the duration
      STR.timerSubscription.cancel();
      STR.timerStream = null;

      ///we stop the pedeometer or stop the walker
      STR.stopListening();
      //call the api with complete status
      DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
      String e_timing = await STR.getProgresstimes(
          hoursStr.value.toString(), minutesStr.value.toString(), secondsStr.value.toString());
      await trackProgressApi(
          event_id: event_id,
          ihl_user_id: event_iHL_User_Id,
          steps: todaySteps.value.toString(),
          distance_covered: kms().toString(),
          event_status: 'complete',
          start_time: '',
          progress_time: e_timing);
      showFromSharedPref = false;
      Get.off(LandingPage());
      //STOP THE TIMER AND PEDEOMETER AND SHOW REPORT SCREEN,
      /// stops button ka on tap function me jo bhi he uke he call krnu  bs...
    } else if (DateTime.now().isAfter(DateTime.parse(event_end_time))) {
      // setState(() {
      stopValue = true;
      pauseValue = false;
      // });

      //stop the duration
      // if(STR.timerStream!=null){
      STR.timerSubscription.cancel();
      STR.timerStream = null;

      ///we stop the pedeometer or stop the walker
      STR.stopListening();
      // }
      //call the api with complete status
      DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
      String e_timing = await STR.getProgresstimes(
          hoursStr.value.toString(), minutesStr.value.toString(), secondsStr.value.toString());
      await trackProgressApi(
          event_id: event_id,
          ihl_user_id: event_iHL_User_Id,
          steps: todaySteps.value.toString(),
          distance_covered: kms().toString(),
          event_status: 'stop',
          start_time: '',
          progress_time: e_timing);
      showFromSharedPref = false;
      Get.off(LandingPage());
      //STOP THE TIMER AND PEDEOMETER AND SHOW REPORT SCREEN,
      /// stops button ka on tap function me jo bhi he uke he call krnu  bs...
    }
    var prefs = await SharedPreferences.getInstance();
    prefs.setString('event_seconds', seconds.toString());
    prefs.setString('event_distance', distance.toString());
    prefs.setString('event_steps', todaySteps.value.toString());
    prefs.setString('event_status', event_status.toString());
    // prefs.setString('event_', todaySteps.value.toString());
  }

  ///steps
  // Platform messages are asynchronous, so we initialize in an async method.
  static Future<void> initPlatformState() async {
    startListening();
  }

  static void startListening() {
    _pedometer = Pedometer();
    _subscription = _pedometer.pedometerStream.listen(
      getTodaySteps,
      onError: _onError,
      onDone: _onDone,
      cancelOnError: true,
    );
  }

  static void _onDone() => print("Finished pedometer tracking");

  static void _onError(error) => print("Flutter Pedometer Error: $error");
  static Pedometer _pedometer;
  static StreamSubscription<int> _subscription;

  static Box<int> stepsBox = Hive.box('steps');
  static void getTodaySteps(int value) async {
    // var stepsBox = await SharedPreferences.getInstance();
    print(value);
    int savedStepsCountKey = 999999;
    int savedStepsCount = stepsBox.get(savedStepsCountKey, defaultValue: 0);

    int todayDayNo = Jiffy(DateTime.now()).dayOfYear;
    if (value < savedStepsCount) {
      // Upon device reboot, pedometer resets. When this happens, the saved counter must be reset as well.
      savedStepsCount = 0;
      // persist this value using a package of your choice here
      stepsBox.put(savedStepsCountKey, savedStepsCount);
    }

    // load the last day saved using a package of your choice here
    int lastDaySavedKey = 888888;
    int lastDaySaved = stepsBox.get(lastDaySavedKey, defaultValue: 0);

    // When the day changes, reset the daily steps count
    // and Update the last day saved as the day changes.
    if (lastDaySaved < todayDayNo) {
      lastDaySaved = todayDayNo;
      savedStepsCount = value;

      stepsBox
        ..put(lastDaySavedKey, lastDaySaved)
        ..put(savedStepsCountKey, savedStepsCount);
    }

    // setState(() {
    todaySteps.value = value - savedStepsCount;
    // });
    stepsBox.put(todayDayNo, todaySteps.value);
    // return todaySteps; // this is your daily steps value.
    _onData(todaySteps.value);
  }

  static int _stepCountValue = 0;
  static var _calorieBurn = '0';
  static void _onData(int newValue) async {
    // var stepsBox = await SharedPreferences.getInstance();
    // todaySteps =  await getTodaySteps(newValue,stepsBox);
    // if (this.mounted) {
    //   setState(() {
    _stepCountValue = newValue;
    setToday();
    getCalorie(todaySteps);
  }

  static Map extracted = {};
  static var started = false;
  static Map allData = {};
  static Map graphData = {};
  static setToday() async {
    ///yha par fate check krlo or use reset krdo
    // allData[genericDateTime(DateTime.now()).toString()] = _stepCountValue;
    // allData[genericDateTime(DateTime.now()).toString()] = todaySteps;
    // var prefs = await SharedPreferences.getInstance();
    // prefs.setString(SPKeys.stepCounterEvent, json.encode(allData));
  }
  // DateTime
  static genericDateTime(DateTime dateTime) {
    String str = dateTime.toString();
    var str1 = str.substring(0, str.indexOf(' '));
    var str2 = str.substring(str1.length + 1, str1.length + 6);
    // return DateTime.parse('$str1 00:00:00');
    var ss = str1 + " " + str2;
    print(ss);
    // return DateTime.parse('$str1 $str2'+':00');
    return '$str1 $str2' + ':00';
  }

  // static var _calorieBurn = '0';
  static getCalorie(step) {
    // double addCal = step/28.571;//100 meter => 3.5 calk
    double addCal = step.value / 22.727; //100 meter => 4.4 cal
    // if (this.mounted) {
    //   setState(() {
    _calorieBurn = addCal.toStringAsFixed(2);
    //   });
    // }
  }

  static void stopListening() {
    _subscription.cancel();
  }

  static getTimeTaken() async {
    var prefs = await SharedPreferences.getInstance();
    // var data1 = prefs.get('data');
    // Map res = jsonDecode(data1);
    // event_iHL_User_Id = res['User']['id'];
    // var e_steps = prefs.getString('event_steps');
    var e_seconds = prefs.getString('event_seconds');
    // stopValue=false;
    // hoursStr.value = int.parse(((newTick / (60 * 60)) % 60)
    //     .floor()
    //     .toString()
    //     .padLeft(2, '0')) ;
    // minutesStr.value = int.parse(((newTick / 60) % 60)
    //     .floor()
    //     .toString()
    //     .padLeft(2, '0'));
    // secondsStr.value = int.parse((newTick % 60).floor().toString().padLeft(2, '0'));
  }
//
// static checkPermission1({event_status,event_id}) async {
//   // await Permission.activityRecognition.request();
//   var status = await Permission.activityRecognition.status;
//   if (status.isGranted) {
//     // await STR.startt('$event_status', widget.eventDetailList[widget.indexed]['event_id']);
//     await STR.startt('$event_status', event_id);
//     await STR.initPlatformState();
//   } else if (status.isDenied) {
//     await Permission.activityRecognition.request();
//     status = await Permission.activityRecognition.status;
//     if (status.isGranted) {
//       await  STR.startt('$event_status', event_id);
//       await STR.initPlatformState();
//     } else{
//       Get.snackbar(
//           'Activity Access Denied', 'Allow Activity permission to continue',
//           backgroundColor: Colors.red,
//           colorText: Colors.white,
//           duration: Duration(seconds: 5),
//           isDismissible: false,
//           mainButton: TextButton(
//             //TextButton(
//             // style: TextButton
//             //     .styleFrom(
//             //   primary:
//             //       Colors.white,
//             // ),
//               onPressed: () async {
//                 await openAppSettings();
//               },
//               child: Text('Allow')));
//     }
//   } else {
//     Get.snackbar(
//         'Activity Access Denied', 'Allow Activity permission to continue',
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//         duration: Duration(seconds: 5),
//         isDismissible: false,
//         mainButton: TextButton(
//             onPressed: () async {
//               await openAppSettings();
//             },
//             child: Text('Allow')));
//   }
// }
}
