import 'dart:convert';
// //import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ihl/repositories/marathon_event_api.dart';
import 'package:ihl/utils/ScUtil.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/views/marathon/e-cetificate_image.dart';
import 'package:ihl/views/marathon/e_certificate.dart';
import 'package:ihl/widgets/BasicPageUI.dart';
import 'package:ihl/widgets/offline_widget.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

// import 'othersEventDetails.dart';
// ValueNotifier<int> apiHoursStr = ValueNotifier<int>(0);
// var apiMinutesStr = ValueNotifier<int>(0);
// ValueNotifier<int> apiSecondsStr =  ValueNotifier<int>(0);
// ValueNotifier<int> apiTodaySteps = ValueNotifier<int>(0);
// var showFromApi = ValueNotifier<bool>(false);
class EventsInProfile extends StatefulWidget {
  @override
  _EventsInProfileState createState() => _EventsInProfileState();
}

class _EventsInProfileState extends State<EventsInProfile> {
  @override
  void initState() {
    getEventDetails();
    super.initState();
  }

  List eventDetailList;
  var userEnrolledMap;
  getEventDetails() async {
    SharedPreferences prefs1 = await SharedPreferences.getInstance();
    var data1 = prefs1.get('data');
    Map res = jsonDecode(data1);
    var iHL_User_Id = res['User']['id'];
    // eventDetailList = await eventDetailApi();
    // userEnrolledMap = await isUserEnrolledApi(ihl_user_id: iHL_User_Id,event_id: eventDetailList[0]['event_id']);
    // eventDetailApi().then((value) async{
    eventDetailList = await eventDetailApi();
    if (eventDetailList != null) {
      // isUserEnrolledApi(ihl_user_id: iHL_User_Id,event_id: eventDetailList[0]['event_id']).then((v){
      userEnrolledMap = await isUserEnrolledApi(
          ihl_user_id: iHL_User_Id, event_id: eventDetailList[0]['event_id']);
      // });
      print(userEnrolledMap.toString());
      print(eventDetailList[0]['event_varients']);
      if (mounted) {
        setState(() {});
      }
    }
    // });
  }

  @override
  Widget build(BuildContext context) {
    return ConnectivityWidgetWrapper(
      disableInteraction: true,
      offlineWidget: OfflineWidget(),
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
                    Get.back(result: [true]);
                  }, //replaces the screen to Main dashboard
                  color: Colors.white,
                ),
                SizedBox(
                  width: ScUtil().setWidth(80),
                ),
                Text(
                  'Events ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: ScUtil().setSp(25),
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.1,
                    // height: 4
                  ),
                  // style: TextStyle(
                  //     color: Colors.white, fontSize: ScUtil().setSp(20.0)),
                ),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            SizedBox(height: 8.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Container(
                width: MediaQuery.of(context).size.width,
                // width: ScUtil().setWidth(width),
                height: ScUtil().setHeight(200),
                child: eventDetailList != null && userEnrolledMap != null
                    ? ProfileEventCard(
                        eventDetailList: eventDetailList,
                        userEnrolledMap: userEnrolledMap,
                      )
                    : Column(
                        children: [
                          Lottie.network(
                              "https://assets8.lottiefiles.com/packages/lf20_zjrmnlsu.json",
                              height: ScUtil().setHeight(155)),
                          Text("Loading...",
                              style: TextStyle(
                                  fontSize: ScUtil().setSp(10),
                                  fontWeight: FontWeight.w600))
                        ],
                      ),
              ),
            ),
            // Marathon section ends
            SizedBox(height: 8.0),
          ],
        ),
      ),
    );
  }
}

class ProfileEventCard extends StatefulWidget {
  ProfileEventCard({this.eventDetailList, this.userEnrolledMap});
  final eventDetailList;
  final userEnrolledMap;
  @override
  _ProfileEventCardState createState() => _ProfileEventCardState();
}

class _ProfileEventCardState extends State<ProfileEventCard> {
  @override
  String eventName = '';
  String eventLocation = '';
  String eventDate = '';
  DateTime eve_date_form;
  String eventImg = '';
  String eventDescription = '';
  DateTime event_end_date;
  bool isUserEnrolled;
  bool loading = false;
  double totalDistance = 0;
  void initState() {
    // TODO: implement initState
    eventName = widget.eventDetailList[0]['event_name'].toString() +
        ' by ' +
        widget.eventDetailList[0]['event_host'].toString();
    eventDescription =
        widget.eventDetailList[0]['event_description'].toString();
    eventImg = widget.eventDetailList[0]['event_image'].toString();
    eventLocation = widget.eventDetailList[0]['event_locations']
        .toString()
        .replaceAll('[', '');
    eventLocation = eventLocation.replaceAll(']', '');
    eventDate = widget.eventDetailList[0]['event_start_time'].toString();
    event_end_date =
        DateTime.parse(widget.eventDetailList[0]['event_end_time'].toString());
    // event_end_date = widget.eventDetailList[0]['event_start_time'].toString();
    eve_date_form = DateTime.parse(eventDate);
    final DateFormat formatter = DateFormat.yMMMMd('en_US').add_jm();
    final String formatted = formatter.format(eve_date_form);
    print(formatted);
    eventDate = formatted;
    isUserEnrolled =
        widget.userEnrolledMap['status'] == 'user not enrolled' ? false : true;
    // if(isUserEnrolled){
    //   totalDistance =  double.parse(widget.userEnrolledMap['event_varient'].toString().replaceAll('Km', ''));
    //   if(widget.userEnrolledMap['event_status']=='complete'||widget.userEnrolledMap['event_status']=='pause'||widget.userEnrolledMap['event_status']=='stop'){
    //     showFromApi.value = true;
    //   }else{
    //     showFromApi.value = false;
    //   }
    //   if(widget.userEnrolledMap['progress_time']!=null&&widget.userEnrolledMap['progress_time']!='') {
    //     // eventDate = widget.eventDetailList[0]['event_start_time'].toString();
    //     // eve_date_form = DateTime.parse(eventDate);
    //
    //
    //     // var str = widget.userEnrolledMap['progress_time'].split(' ');
    //     var ddd = widget.userEnrolledMap['progress_time'].toString();
    //     var ab = ddd.substring(11,19);
    //     var str = DateTime.parse(ddd);
    //     print(str);
    //     final DateFormat fff = DateFormat('yyyy-MM-dd hh:mm:ss');
    //     final String fmt = fff.format(str);
    //     print('####################################################################'+fmt);
    //     var str1 = fmt.split(' ');
    //     // var timeList = str[1].split(':');
    //     // var timeList = str1[1].split(':');
    //     var timeList = ab.split(':');
    //     apiHoursStr.value = int.parse(timeList[0]);
    //     apiMinutesStr.value = int.parse(timeList[1]);
    //     apiSecondsStr.value = int.parse(timeList[2]);
    //   }
    //   apiTodaySteps.value = int.parse(widget.userEnrolledMap['steps']);//steps
    // }
    super.initState();
    if (this.mounted) {
      setState(() {
        loading = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // isUserEnrolled = false;
    if (loading) {
      if (isUserEnrolled &&
          (widget.userEnrolledMap['event_status'] == 'stop' ||
              widget.userEnrolledMap['event_status'] == 'complete')) {
        if (widget.userEnrolledMap['using_ihl_app'] == 'IHL Care') {
          return Container(
            // height: MediaQuery.of(context).size.height / 2.9,
            width: MediaQuery.of(context).size.width,
            //  width: ScUtil().setWidth(110),
            // height: ScUtil().setHeight(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: DecorationImage(
                  image: AssetImage(
                    'assets/images/marathon3.jpg',
                  ),
                  fit: BoxFit.cover),
            ),
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
                  // SizedBox(
                  //   height: 8.0,
                  // ),
                  Center(
                    child: Text(
                      // 'Persistent Marathon Challenge',
                      '$eventName',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: ScUtil().setSp(14),
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.0,
                          height: 3),
                    ),
                  ),
                  Visibility(
                    // visible: !(DateTime.now().compareTo(eve_date_form)>=0)&&!isUserEnrolled,
                    // visible: widget.userEnrolledMap['event_status']==null||widget.userEnrolledMap['event_status']=='enrolled',
                    child: Center(
                      child: Text(
                        // 'Date: 9th Janaury 2022',
                        'Date: $eventDate',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: ScUtil().setSp(14),
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                            height: 3),
                      ),
                    ),
                  ),
                  // Visibility(
                  //   visible: statusText() != 'stop' || statusText() != 'complete',
                  //   child: Padding(
                  //     padding: const EdgeInsets.only(top: 10.0),
                  //     child: ElevatedButton(
                  //       style: ElevatedButton.styleFrom(
                  //         shape: RoundedRectangleBorder(
                  //           borderRadius: BorderRadius.circular(20.0),
                  //         ),
                  //         primary: Colors.black.withOpacity(0.7),
                  //         textStyle: TextStyle(
                  //             fontSize: 16, fontWeight: FontWeight.bold),
                  //       ),
                  //       // onPressed: () {
                  //       //   if (isUserEnrolled == false) {
                  //       //     Get.to(
                  //       //       MarathonDetails(
                  //       //         img: eventImg,
                  //       //         description: eventDescription,
                  //       //         name: eventName,
                  //       //         start: false,
                  //       //         eventDetailList: widget.eventDetailList,
                  //       //       ),
                  //       //     );
                  //       //   } else {
                  //       //     Get.to(
                  //       //       MarathonDetails(
                  //       //         img: eventImg,
                  //       //         description: eventDescription,
                  //       //         name: eventName,
                  //       //         start: true,
                  //       //         eventDetailList: widget.eventDetailList,
                  //       //       ),
                  //       //     );}},
                  //       child: Text(
                  //         // isUserEnrolled == false ? 'Enroll Me' : status==null? 'Start': status==''completed'?'ccc',
                  //         isUserEnrolled == true ? statusText() : 'Enroll Me',
                  //         style: TextStyle(
                  //             color: Colors.white,
                  //             letterSpacing: 1.5,
                  //             fontSize: ScUtil().setSp(14)),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  Visibility(
                    // visible: (DateTime.now().compareTo(eve_date_form)<=0),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          primary: Colors.black.withOpacity(0.7),
                          textStyle: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        onPressed: () {},
                        child: DateTime.now().isBefore(event_end_date)
                            ? Text(
                                // isUserEnrolled == false ? 'Enroll Me' : status==null? 'Start': status==''completed'?'ccc',
                                isUserEnrolled == true
                                    ? statusText()
                                    : 'Enroll Me',
                                style: TextStyle(
                                    color: Colors.white,
                                    letterSpacing: 1.5,
                                    fontSize: ScUtil().setSp(14)),
                              )
                            : Text(
                                // isUserEnrolled == false ? 'Enroll Me' : status==null? 'Start': status==''completed'?'ccc',
                                'Expired',
                                style: TextStyle(
                                    color: Colors.white,
                                    letterSpacing: 1.5,
                                    fontSize: ScUtil().setSp(14)),
                              ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: ScUtil().setHeight(10),
                  ),
                  Visibility(
                    visible: widget.userEnrolledMap['event_status'] == 'stop' ||
                        widget.userEnrolledMap['event_status'] == 'complete',
                    child: InkWell(
                      onTap: () async {
                        var name = widget.userEnrolledMap['user_name'] == null
                            ? "Name"
                            : widget.userEnrolledMap['user_name'];
                        var status =
                            widget.userEnrolledMap['event_status'] == null
                                ? "completed"
                                : widget.userEnrolledMap['event_status'];
                        var varient =
                            widget.userEnrolledMap['event_varient'] == null
                                ? "5 KM"
                                : widget.userEnrolledMap['event_varient'];
                        var time_text =
                            widget.userEnrolledMap['closed_time_by_user'] ==
                                    null
                                ? "2022-01-01'T'01:33:06.000'Z"
                                : widget.userEnrolledMap['closed_time_by_user'];
                        var employee_id =
                            widget.userEnrolledMap['employee_id'] == null
                                ? "001"
                                : widget.userEnrolledMap['employee_id'];
                        DateTime dateTime =
                            new DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z")
                                .parse(time_text);
                        var completed_time = DateFormat('hh:mm a')
                            .format(DateTime.parse(dateTime.toString()));
                        Get.to(EcertificateImage(
                            name_participent: name,
                            event_status: status,
                            event_varient: varient,
                            time_taken: completed_time,
                            emp_id: employee_id));
                        // await Permission.storage.request();
                        // AwesomeNotifications().cancelAll();
                        // final status = await Permission.storage.request();
                        // if (status.isGranted) {
                        //   Get.snackbar(
                        //     '',
                        //     'Your E-certificate will be saved in your mobile!',
                        //     backgroundColor: AppColors.primaryAccentColor,
                        //     colorText: Colors.white,
                        //     duration: Duration(seconds: 5),
                        //     isDismissible: false,
                        //   );
                        //   new Future.delayed(new Duration(seconds: 2), () {
                        //     eCertificate(
                        //         context,
                        //         widget.userEnrolledMap['user_name'],
                        //         widget.userEnrolledMap['event_status'],
                        //         widget.userEnrolledMap['varient_selected'],
                        //         widget.userEnrolledMap['closed_time_by_user'],
                        //         widget.userEnrolledMap['employee_id']);
                        //   });
                        // } else if (status.isDenied) {
                        //   await Permission.storage.request();
                        //   Get.snackbar('Storage Access Denied',
                        //       'Allow Storage permission to continue',
                        //       backgroundColor: Colors.red,
                        //       colorText: Colors.white,
                        //       duration: Duration(seconds: 5),
                        //       isDismissible: false,
                        //       mainButton: TextButton(
                        //           onPressed: () async {
                        //             await openAppSettings();
                        //           },
                        //           child: Text('Allow')));
                        // } else {
                        //   Get.snackbar(
                        //     'Storage Access Denied',
                        //     'Allow Storage permission to continue',
                        //     backgroundColor: Colors.red,
                        //     colorText: Colors.white,
                        //     duration: Duration(seconds: 5),
                        //     isDismissible: false,
                        //     mainButton: TextButton(
                        //       onPressed: () async {
                        //         await openAppSettings();
                        //       },
                        //       child: Text('Allow'),
                        //     ),
                        //   );
                        // }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              primary: Colors.black.withOpacity(0.7),
                              textStyle: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            onPressed: () {},
                            child: Text(
                              // isUserEnrolled == false ? 'Enroll Me' : status==null? 'Start': status==''completed'?'ccc',
                              'Download Certificate',
                              style: TextStyle(
                                  color: Colors.white,
                                  letterSpacing: 1.5,
                                  fontSize: ScUtil().setSp(14)),
                            ),
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
                            width: ScUtil().setWidth(40),
                            height: ScUtil().setHeight(30),
                            child: Icon(
                              Icons.download,
                              color: AppColors.primaryAccentColor,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          return Container(
            // height: MediaQuery.of(context).size.height / 2.9,
            width: MediaQuery.of(context).size.width,
            //  width: ScUtil().setWidth(110),
            // height: ScUtil().setHeight(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: DecorationImage(
                  image: AssetImage(
                    'assets/images/marathon3.jpg',
                  ),
                  fit: BoxFit.cover),
            ),
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
                  // SizedBox(
                  //   height: 8.0,
                  // ),
                  Center(
                    child: Text(
                      // 'Persistent Marathon Challenge',
                      '$eventName',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: ScUtil().setSp(14),
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.0,
                          height: 3),
                    ),
                  ),
                  Visibility(
                    // visible: !(DateTime.now().compareTo(eve_date_form)>=0)&&!isUserEnrolled,
                    // visible: widget.userEnrolledMap['event_status']==null||widget.userEnrolledMap['event_status']=='enrolled',
                    child: Center(
                      child: Text(
                        // 'Date: 9th Janaury 2022',
                        'Date: $eventDate',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: ScUtil().setSp(14),
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                            height: 3),
                      ),
                    ),
                  ),
                  Visibility(
                    // visible: (DateTime.now().compareTo(eve_date_form)<=0),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          primary: Colors.black.withOpacity(0.7),
                          textStyle: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        onPressed: () {},
                        child: DateTime.now().isBefore(event_end_date)
                            ? Text(
                                // isUserEnrolled == false ? 'Enroll Me' : status==null? 'Start': status==''completed'?'ccc',
                                isUserEnrolled == true
                                    ? statusText()
                                    : 'Please Enrolled First',
                                style: TextStyle(
                                    color: Colors.white,
                                    letterSpacing: 1.5,
                                    fontSize: ScUtil().setSp(14)),
                              )
                            : Text(
                                'Expired',
                                style: TextStyle(
                                    color: Colors.white,
                                    letterSpacing: 1.5,
                                    fontSize: ScUtil().setSp(14)),
                              ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: ScUtil().setHeight(10),
                  ),
                  Visibility(
                    visible: widget.userEnrolledMap['event_status'] == 'stop' ||
                        widget.userEnrolledMap['event_status'] == 'complete',
                    child: InkWell(
                      onTap: () async {
                        var name = widget.userEnrolledMap['user_name'] == null
                            ? "Name"
                            : widget.userEnrolledMap['user_name'];
                        var status =
                            widget.userEnrolledMap['event_status'] == null
                                ? "completed"
                                : widget.userEnrolledMap['event_status'];
                        var varient =
                            widget.userEnrolledMap['event_varient'] == null
                                ? "5 KM"
                                : widget.userEnrolledMap['event_varient'];
                        var time_text =
                            widget.userEnrolledMap['closed_time_by_user'] ==
                                    null
                                ? "2022-01-01'T'01:33:06.000'Z"
                                : widget.userEnrolledMap['closed_time_by_user'];
                        var employee_id =
                            widget.userEnrolledMap['employee_id'] == null
                                ? "001"
                                : widget.userEnrolledMap['employee_id'];
                        DateTime dateTime =
                            new DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z")
                                .parse(time_text);
                        var completed_time = DateFormat('hh:mm a')
                            .format(DateTime.parse(dateTime.toString()));
                        Get.to(EcertificateImage(
                            name_participent: name,
                            event_status: status,
                            event_varient: varient,
                            time_taken: completed_time,
                            emp_id: employee_id));
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              primary: Colors.black.withOpacity(0.7),
                              textStyle: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            onPressed: () {},
                            child: Text(
                              // isUserEnrolled == false ? 'Enroll Me' : status==null? 'Start': status==''completed'?'ccc',
                              'Download Certificate',
                              style: TextStyle(
                                  color: Colors.white,
                                  letterSpacing: 1.5,
                                  fontSize: ScUtil().setSp(14)),
                            ),
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
                            width: ScUtil().setWidth(40),
                            height: ScUtil().setHeight(30),
                            child: Icon(
                              Icons.download,
                              color: AppColors.primaryAccentColor,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      }

      ///user not enrolled in any event
      else {
        return Center(
          child: Text(
            'No Certificate Available!!!',
            style: TextStyle(color: AppColors.primaryColor, fontSize: 22),
          ),
        );
      }
    } else {
      return CircularProgressIndicator();
    }
  }

  String statusText() {
    var status = widget.userEnrolledMap['event_status'];
    print('----------$status');
    if (status == "" || status == null) {
      return "Start";
    } else if (status == "pause") {
      return "Resume";
    } else if (status == "complete") {
      return "Completed";
    } else if (status == "stop") {
      return "Stopped";
    } else if (status == "enrolled") {
      return "start";
    } else {
      return "Progress";
    }
  }
}
