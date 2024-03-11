import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ihl/utils/ScUtil.dart';
import 'package:ihl/utils/app_colors.dart';
// import 'package:ihl/constants/routes.dart';
import 'package:ihl/views/marathon/marathon_details.dart';
import 'package:ihl/views/screens.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'othersEventDetails.dart';

ValueNotifier<int> apiHoursStr = ValueNotifier<int>(0);
var apiMinutesStr = ValueNotifier<int>(0);
ValueNotifier<int> apiSecondsStr = ValueNotifier<int>(0);
ValueNotifier<int> apiTodaySteps = ValueNotifier<int>(0);
var showFromApi = ValueNotifier<bool>(false);

class MarathonCard extends StatefulWidget {
  MarathonCard({this.eventDetailList, this.userEnrolledMap, this.indexx});
  final eventDetailList;
  final userEnrolledMap;
  final indexx;
  @override
  _MarathonCardState createState() => _MarathonCardState();
}

class _MarathonCardState extends State<MarathonCard> {
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
    eventName = widget.eventDetailList[widget.indexx]['event_name'].toString() +
        ' by ' +
        widget.eventDetailList[widget.indexx]['event_host'].toString();
    eventDescription =
        widget.eventDetailList[widget.indexx]['event_description'].toString();
    eventImg = widget.eventDetailList[widget.indexx]['event_image'].toString();
    eventLocation = widget.eventDetailList[widget.indexx]['event_locations']
        .toString()
        .replaceAll('[', '');
    eventLocation = eventLocation.replaceAll(']', '');
    eventDate =
        widget.eventDetailList[widget.indexx]['event_start_time'].toString();
    event_end_date = DateTime.parse(
        widget.eventDetailList[widget.indexx]['event_end_time'].toString());
    // event_end_date = widget.eventDetailList[widget.indexx]['event_start_time'].toString();
    eve_date_form = DateTime.parse(eventDate);
    final DateFormat formatter = DateFormat.yMMMMd('en_US').add_jm();
    final String formatted = formatter.format(eve_date_form);
    print(formatted);
    eventDate = formatted;
    isUserEnrolled =
        widget.userEnrolledMap['status'] == 'user not enrolled' ? false : true;
    if (isUserEnrolled) {
      totalDistance = double.parse(widget.userEnrolledMap['event_varient']
          .toString()
          .replaceAll('Km', ''));
      if (widget.userEnrolledMap['event_status'] == 'complete' ||
          widget.userEnrolledMap['event_status'] == 'pause' ||
          widget.userEnrolledMap['event_status'] == 'stop' ||
          showFromSharedPref) {
        showFromApi.value = true;
      } else {
        showFromApi.value = false;
      }
      if (widget.userEnrolledMap['progress_time'] != null &&
          widget.userEnrolledMap['progress_time'] != '') {
        // eventDate = widget.eventDetailList[widget.indexx]['event_start_time'].toString();
        // eve_date_form = DateTime.parse(eventDate);

        // var str = widget.userEnrolledMap['progress_time'].split(' ');
        var ddd = widget.userEnrolledMap['progress_time'].toString();
        var ab = ddd.substring(11, 19);
        var str = DateTime.parse(ddd);
        print(str);
        final DateFormat fff = DateFormat('yyyy-MM-dd hh:mm:ss');
        final String fmt = fff.format(str);
        print(
            '####################################################################' +
                fmt);
        var str1 = fmt.split(' ');
        // var timeList = str[1].split(':');
        // var timeList = str1[1].split(':');
        var timeList = ab.split(':');
        apiHoursStr.value = int.parse(timeList[widget.indexx]);
        apiMinutesStr.value = int.parse(timeList[1]);
        apiSecondsStr.value = int.parse(timeList[2]);
      }
      apiTodaySteps.value = int.parse(widget.userEnrolledMap['steps']); //steps
    }
    super.initState();
    setState(() {
      loading = true;
    });
  }
  marathonCardOnTap(){
    if (isUserEnrolled == false &&
        DateTime.now().isBefore(event_end_date)) {
      Get.to(
        MarathonDetails(
          indexed: widget.indexx,
          img: eventImg,
          description: eventDescription,
          name: eventName,
          start: false,
          eventDetailList: widget.eventDetailList,
          userEnrolledMap: widget.userEnrolledMap,
        ),
      );
    }
    else if(isUserEnrolled == false &&
    DateTime.now().isAfter(event_end_date)){
    Get.snackbar(
    'Expired', 'Event is Expired',
    backgroundColor: Colors.red,
    colorText: Colors.white,
    duration: Duration(seconds: 3),
    isDismissible: true,
    snackPosition: SnackPosition.BOTTOM,
    );
    }
    else if(isUserEnrolled == true &&
    DateTime.now().isBefore(eve_date_form)){
    Get.snackbar(
    'Wait...', 'Event is Not Started yet',
    backgroundColor: Colors.blue,
    colorText: Colors.white,
    duration: Duration(seconds: 3),
    isDismissible: true,
    snackPosition: SnackPosition.BOTTOM,
    );
    }
    else {
      if (DateTime.now().isAfter(eve_date_form)) {
        checkPermissionFullCard();
      }
    }
  }
  usingOtherAppOnTap(){
    if (isUserEnrolled == false &&
        DateTime.now().isBefore(event_end_date)) {
      //for registration
      Get.to(
        MarathonDetails(
          indexed: widget.indexx,
          img: eventImg,
          description: eventDescription,
          name: eventName,
          start: false,
          eventDetailList: widget.eventDetailList,
          userEnrolledMap: widget.userEnrolledMap,
        ),
      );
    } else if (isUserEnrolled == true &&
        DateTime.now().isAfter(eve_date_form) &&
        (widget.userEnrolledMap['event_status'] != 'complete' &&
            widget.userEnrolledMap['event_status'] != 'stop')) {
      Get.to(OthersDetail(
        eventDetailList: widget.eventDetailList,
        userEnrolledMap: widget.userEnrolledMap,
      ));
    } else if (isUserEnrolled == true &&
        DateTime.now().isAfter(eve_date_form) &&
        (widget.userEnrolledMap['event_status'] == 'complete' ||
            widget.userEnrolledMap['event_status'] == 'stop')) {
      Get.to(
        MarathonDetails(
          indexed: widget.indexx,
          img: eventImg,
          description: eventDescription,
          name: eventName,
          start: true,
          eventDetailList: widget.eventDetailList,
          userEnrolledMap: widget.userEnrolledMap,
        ),
      );
    }
    else if(isUserEnrolled == false &&
        DateTime.now().isAfter(event_end_date)){
      Get.snackbar(
        'Expired', 'Event is Expired',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
        isDismissible: true,
        snackPosition: SnackPosition.BOTTOM,
        // mainButton: TextButton(
        //     onPressed: () async {
        //       await openAppSettings();
        //     },
        //     child: Text('Allow'))
      );
    }
    else if(isUserEnrolled == true &&
        DateTime.now().isBefore(eve_date_form)){
      Get.snackbar(
        'Wait...', 'Event is Not Started yet',
        backgroundColor: Colors.blue,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
        isDismissible: true,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool showResult = false;
    if (loading) {
      if (widget.userEnrolledMap['using_ihl_app'] == 'IHL Care') {
        return GestureDetector(
          onTap: () {
            // if (isUserEnrolled == true) {
           marathonCardOnTap();
          },
          child: Padding(
            padding: EdgeInsets.only(
                left: ScUtil().setWidth(4),
                right: ScUtil().setWidth(4),
                top: ScUtil().setHeight(16),
                bottom: ScUtil().setHeight(18)),
            child: Container(
              // margin: EdgeInsets.only(bottom: ScUtil().setHeight(8)),
              // height: MediaQuery.of(context).size.height / 2.9,
              width: MediaQuery.of(context).size.width,
              //  width: ScUtil().setWidth(110),
              // height: ScUtil().setHeight(20),
              // decoration: BoxDecoration(
              //   borderRadius: BorderRadius.circular(20),
              //   image: DecorationImage(
              //       image: AssetImage(
              //         'assets/images/marathon3.jpg',
              //       ),
              //       fit: BoxFit.cover),
              // ),
              ///asdfghjk
              decoration: BoxDecoration(
                color: FitnessAppTheme.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8.0),
                    bottomLeft: Radius.circular(8.0),
                    bottomRight: Radius.circular(8.0),
                    topRight: Radius.circular(68.0)),
                // image: DecorationImage(
                //     image: AssetImage(
                //       'assets/images/marathon3.jpg',
                //     ),
                //     fit: BoxFit.cover),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                      color: FitnessAppTheme.grey.withOpacity(0.2),
                      // color: FitnessAppTheme.nea,
                      offset: Offset(1.1, 1.1),
                      blurRadius: 10.0),
                ],
              ),
              ///asdfghjk
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                // mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: ScUtil().setWidth(12)),
                    child: Center(
                      child: Text(
                        // 'Persistent Marathon Challenge',
                        '$eventName',
                        softWrap: true,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            // color: AppColors.primaryAccentColor,
                            color: FitnessAppTheme.grey,
                            fontSize: ScUtil().setSp(14),
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.0,
                            height: 3),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: widget.userEnrolledMap['event_status'] == null ||
                        widget.userEnrolledMap['event_status'] == 'enrolled',
                    child: Center(
                      child: Text(
                        // 'Date: 9th Janaury 2022',
                        'Date: $eventDate',
                        style: TextStyle(
                            // color: Colors.white,
                            color: AppColors.primaryAccentColor,
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
                  //       //       MarathonDetails( indexed:widget.indexx,
                  //       //         img: eventImg,
                  //       //         description: eventDescription,
                  //       //         name: eventName,
                  //       //         start: false,
                  //       //         eventDetailList: widget.eventDetailList,
                  //       //       ),
                  //       //     );
                  //       //   } else {
                  //       //     Get.to(
                  //       //       MarathonDetails( indexed:widget.indexx,
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
                          primary: DateTime.now().isBefore(event_end_date) ? AppColors.primaryAccentColor:Colors.grey,
                          textStyle: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        onPressed: (){
                          /// write for testing
                          // Get.to(
                          //           MarathonDetails( indexed:widget.indexx,
                          //             img: eventImg,
                          //             description: eventDescription,
                          //             name: eventName,
                          //             start: false,
                          //             eventDetailList: widget.eventDetailList,
                          //           ),
                          //         );
                          marathonCardOnTap();
                        },
                        ///
                        child: DateTime.now().isBefore(event_end_date)
                            ? Text(
                          // isUserEnrolled == false ? 'Enroll Me' : status==null? 'Start': status==''completed'?'ccc',
                          isUserEnrolled == true
                              ? statusText()
                              : 'Enroll Me',
                          style: TextStyle(
                              color: Colors.white,
                              letterSpacing: 0.7,
                              fontSize: ScUtil().setSp(14)),
                        )
                            : Text(
                          // isUserEnrolled == false ? 'Enroll Me' : status==null? 'Start': status==''completed'?'ccc',
                          'Expired',
                          style: TextStyle(
                              color: Colors.white,
                              letterSpacing: 0.7,
                              fontSize: ScUtil().setSp(14)),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(
                    height: ScUtil().setHeight(10),
                  ),

                  Visibility(
                    // visible: false,
                    visible: widget.userEnrolledMap['event_status'] != null &&
                        widget.userEnrolledMap['event_status'] != 'enrolled',
                    // visible: widget.userEnrolledMap['event_status']!=null&&widget.userEnrolledMap['event_status']!='enrolled'&&showFromSharedPref!=true,
                    child: Container(
                      width: MediaQuery.of(context).size.width,

                      //  width: ScUtil().setWidth(110),
                      height: ScUtil().setHeight(60),
                      child: showFromApi.value == false
                          ? Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          /// Duration Card starts
                          Container(
                            // height: 80,
                            // width: 120,
                            width: ScUtil().setWidth(100),
                            height: ScUtil().setHeight(70),
                            child: Card(
                              elevation: 0,
                                child: Column(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Text(
                                      'Duration',
                                      style: TextStyle(
                                        fontFamily:
                                        FitnessAppTheme.fontName,
                                        fontWeight: FontWeight.w500,
                                        fontSize: ScUtil().setSp(16),
                                        color: FitnessAppTheme.grey,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                    Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        children: [
                                          ValueListenableBuilder(
                                            // valueListenable: showFromApi.value==false?hoursStr:apiHoursStr,
                                            valueListenable: hoursStr,
                                            builder:
                                                (context, value, widget) {
                                              String v = value.toString();
                                              if (value.toString().length <
                                                  2) {
                                                v = '0' + value.toString();
                                              }
                                              return Text(
                                                v.toString() + ":",
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  letterSpacing: 1.5,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize:
                                                  ScUtil().setSp(14),
                                                ),
                                              );
                                            },
                                          ),

                                          SizedBox(
                                            width: ScUtil().setWidth(1),
                                          ),

                                          ValueListenableBuilder(
                                            valueListenable: minutesStr,
                                            builder:
                                                (context, value, widget) {
                                              String v = value.toString();
                                              print('Stream->Seconds =>>' +
                                                  value.toString());
                                              if (value.toString().length <
                                                  2) {
                                                v = '0' + value.toString();
                                              }

                                              return Text(
                                                v.toString() + ":",
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  letterSpacing: 1.5,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize:
                                                  ScUtil().setSp(14),
                                                ),
                                              );
                                            },
                                          ),

                                          SizedBox(
                                            width: ScUtil().setWidth(1),
                                          ),
                                          ValueListenableBuilder(
                                            valueListenable: secondsStr,
                                            builder:
                                                (context, value, widget) {
                                              String v = value.toString();
                                              if (value.toString().length <
                                                  2) {
                                                v = '0' + value.toString();
                                              }

                                              return Text(
                                                v.toString(),
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  letterSpacing: 1.5,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize:
                                                  ScUtil().setSp(14),
                                                ),
                                              );
                                            },
                                          ),

                                          // buildTimeCard(time: minutesStr.toString(), header:'MINUTES'),
                                          // SizedBox(width: ScUtil().setWidth(15),),
                                          // buildTimeCard(time: secondsStr.toString(), header:'SECONDS'),
                                        ]),
                                  ],
                                )),
                          ),
                          // Duration Card ends

                          // Remaining Card starts
                          Visibility(
                            // visible: false,
                            visible:
                            widget.userEnrolledMap['event_status'] !=
                                'pause',
                            child: Container(
                              width: ScUtil().setWidth(100),
                              height: ScUtil().setHeight(70),
                              child: Card(
                                elevation: 0,
                                  child: Column(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text(
                                        'Remaining',
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontFamily:
                                          FitnessAppTheme.fontName,
                                          fontWeight: FontWeight.w500,
                                          fontSize: ScUtil().setSp(15),
                                          color: FitnessAppTheme.grey,
                                          letterSpacing: 0.2,
                                        ),
                                        // style: TextStyle(
                                        //     color: Colors.blueAccent,
                                        //     letterSpacing: 0.7,
                                        //     fontWeight: FontWeight.w600,
                                        //     fontSize: ScUtil().setSp(17)),
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          ValueListenableBuilder(
                                            valueListenable: todaySteps,
                                            builder: (context, value, widget) {
                                              String v = value.toString();
                                              // if(value.toString().length<2){
                                              //   v= STR.kms(steps: value.toString()).toString();
                                              // }

                                              return Text(
                                                "${(totalDistance - STR.kmsWithSteps(steps: value.toString())).toStringAsFixed(2)} ",
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  letterSpacing: 1.5,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: ScUtil().setSp(14),
                                                ),
                                              );
                                            },
                                          ),
                                         Text('KM',style: TextStyle(
                                           fontFamily:
                                           FitnessAppTheme.fontName,
                                           fontWeight: FontWeight.w600,
                                           fontSize: ScUtil().setSp(14),
                                           letterSpacing: -0.2,
                                           color: FitnessAppTheme.grey
                                               .withOpacity(0.5),
                                         ),)
                                        ],
                                      ),

                                    ],
                                  )),
                            ),
                          ),
                          Visibility(
                            visible:
                            widget.userEnrolledMap['event_status'] ==
                                'pause',
                            child: FloatingActionButton(
                              backgroundColor: Colors.white,
                              child: Icon(
                                Icons.play_arrow,
                                color: Colors.blue,
                                size: 35,
                              ),
                              elevation: 200,
                              onPressed: () async {
                                setState(() {
                                  pauseValue = true;
                                });
                                // widget.userEnrolledMap['event_status'] = 'resume';
                                // STR.startt('resume',widget.eventDetailList[widget.indexx]['event_id']);
                                // STR.initPlatformState();
                                checkPermission1(
                                    event_status: 'resume',
                                    event_id: widget.eventDetailList[
                                    widget.indexx]['event_id']);
                              },
                            ),
                          ),

                          Container(
                            width: ScUtil().setWidth(100),
                            height: ScUtil().setHeight(70),
                            child: Card(
                              elevation: 0,
                              child: Column(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(
                                    'Covered',
                                    style: TextStyle(
                                      fontFamily:
                                      FitnessAppTheme.fontName,
                                      fontWeight: FontWeight.w500,
                                      fontSize: ScUtil().setSp(16),
                                      color: FitnessAppTheme.grey,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ValueListenableBuilder(
                                        valueListenable: todaySteps,
                                        builder: (context, value, widget) {
                                          String v = value.toString();
                                          // if(value.toString().length<2){
                                          //   v= STR.kms(steps: value.toString()).toString();
                                          // }

                                          return Text(
                                            // "${STR.kmsWithSteps(steps: value.toString())} KM", style: TextStyle(
                                            STR
                                                .kmsWithSteps(
                                                steps: value
                                                    .toString())
                                                .toString()
                                                .length <
                                                4
                                                ? "${STR.kmsWithSteps(steps: value.toString())}0 "
                                                : "${STR.kmsWithSteps(steps: value.toString())} ",
                                            style: TextStyle(
                                              color: Colors.black,
                                              letterSpacing: 1.5,
                                              fontWeight: FontWeight.w600,
                                              fontSize: ScUtil().setSp(14),
                                            ),
                                          );
                                        },
                                      ),
                                      Text('KM',style: TextStyle(
                                        fontFamily:
                                        FitnessAppTheme.fontName,
                                        fontWeight: FontWeight.w600,
                                        fontSize: ScUtil().setSp(14),
                                        letterSpacing: -0.2,
                                        color: FitnessAppTheme.grey
                                            .withOpacity(0.5),
                                      ),),
                                    ],
                                  ),

                                ],
                              ),
                            ),
                          )
                          // Covered Card ends
                        ],
                      )
                          : Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          /// Duration Card starts
                          Container(
                            // height: 80,
                            // width: 120,
                            width: ScUtil().setWidth(100),
                            height: ScUtil().setHeight(70),
                            child: Card(
                              elevation: 0,
                                child: Column(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Text(
                                      'Duration',
                                      style: TextStyle(
                                        fontFamily:
                                        FitnessAppTheme.fontName,
                                        fontWeight: FontWeight.w500,
                                        fontSize: ScUtil().setSp(16),
                                        color: FitnessAppTheme.grey,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                    Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        children: [
                                          ValueListenableBuilder(
                                            // valueListenable: showFromApi.value==false?hoursStr:apiHoursStr,
                                            valueListenable: apiHoursStr,
                                            builder:
                                                (context, value, widget) {
                                              String v = value.toString();
                                              if (value.toString().length <
                                                  2) {
                                                v = '0' + value.toString();
                                              }
                                              return Text(
                                                v.toString() + ":",
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  letterSpacing: 0.5,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize:
                                                  ScUtil().setSp(14),
                                                ),
                                              );
                                            },
                                          ),

                                          SizedBox(
                                            width: ScUtil().setWidth(1),
                                          ),

                                          ValueListenableBuilder(
                                            valueListenable: apiMinutesStr,
                                            builder:
                                                (context, value, widget) {
                                              String v = value.toString();
                                              if (value.toString().length <
                                                  2) {
                                                v = '0' + value.toString();
                                              }

                                              return Text(
                                                v.toString() + ":",
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  letterSpacing: 0.5,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize:
                                                  ScUtil().setSp(14),
                                                ),
                                              );
                                            },
                                          ),

                                          SizedBox(
                                            width: ScUtil().setWidth(1),
                                          ),
                                          ValueListenableBuilder(
                                            valueListenable: apiSecondsStr,
                                            builder:
                                                (context, value, widget) {
                                              String v = value.toString();
                                              if (value.toString().length <
                                                  2) {
                                                v = '0' + value.toString();
                                              }

                                              return Text(
                                                v.toString(),
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  letterSpacing: 0.5,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize:
                                                  ScUtil().setSp(14),
                                                ),
                                              );
                                            },
                                          ),
                                        ]),
                                  ],
                                )),
                          ),
                          // Duration Card ends

                          // Remaining Card starts
                          Visibility(
                            // visible: false,
                            visible:
                            widget.userEnrolledMap['event_status'] !=
                                'pause',
                            child: Container(
                              width: ScUtil().setWidth(100),
                              height: ScUtil().setHeight(70),
                              child: Card(
                                elevation: 0,
                                  child: Column(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text(
                                        'Remaining',
                                        style: TextStyle(
                                          fontFamily:
                                          FitnessAppTheme.fontName,
                                          fontWeight: FontWeight.w500,
                                          fontSize: ScUtil().setSp(16),
                                          color: FitnessAppTheme.grey,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            // '2.03 KM',
                                            "${(totalDistance - STR.kmsWithSteps(steps: apiTodaySteps.value)).toStringAsFixed(2)} ",
                                            style: TextStyle(
                                              color: Colors.black,
                                              letterSpacing: 0.5,
                                              fontWeight: FontWeight.w600,
                                              fontSize: ScUtil().setSp(14),
                                            ),
                                          ),
                                          Text(
                                            "KM",
                                            style: TextStyle(
                                              fontFamily:
                                              FitnessAppTheme.fontName,
                                              fontWeight: FontWeight.w600,
                                              fontSize: ScUtil().setSp(14),
                                              letterSpacing: -0.2,
                                              color: FitnessAppTheme.grey
                                                  .withOpacity(0.5),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  )),
                            ),
                          ),
                          Visibility(
                            visible:
                            widget.userEnrolledMap['event_status'] ==
                                'pause',
                            child: FloatingActionButton(
                              backgroundColor: Colors.white,
                              child: Icon(
                                Icons.play_arrow,
                                color: Colors.blue,
                                size: 35,
                              ),
                              elevation: 200,
                              onPressed: () {
                                setState(() {
                                  pauseValue = true;
                                });
                                checkPermission2(
                                    event_id: widget.eventDetailList[
                                    widget.indexx]['event_id'],
                                    event_status: 'resume');
                              },
                            ),
                          ),

                          Container(
                            width: ScUtil().setWidth(100),
                            height: ScUtil().setHeight(70),
                            child: Card(
                              elevation: 0,
                              child: Column(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(
                                    'Covered',
                                    style: TextStyle(
                                      fontFamily:
                                      FitnessAppTheme.fontName,
                                      fontWeight: FontWeight.w500,
                                      fontSize: ScUtil().setSp(16),
                                      color: FitnessAppTheme.grey,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        // '7.97 KM',
                                        // "${STR.kmsWithSteps(steps: apiTodaySteps.value.toString())} KM",
                                        // STR.kmsWithSteps(steps: value.toString()).toString().length<4?"${STR.kmsWithSteps(steps: value.toString())}0 KM":"${STR.kmsWithSteps(steps: value.toString())} KM", style: TextStyle(

                                        STR
                                            .kmsWithSteps(
                                            steps: apiTodaySteps
                                                .value
                                                .toString())
                                            .toString()
                                            .length <
                                            4
                                            ? "${STR.kmsWithSteps(steps: apiTodaySteps.value.toString())}0 "
                                            : "${STR.kmsWithSteps(steps: apiTodaySteps.value.toString())} ",
                                        style: TextStyle(
                                          color: Colors.black,
                                          letterSpacing: 0.5,
                                          fontWeight: FontWeight.w600,
                                          fontSize: ScUtil().setSp(14),
                                        ),
                                      ),
                                      Text(
                                        'KM',
                                        style: TextStyle(
                                          fontFamily:
                                          FitnessAppTheme.fontName,
                                          fontWeight: FontWeight.w600,
                                          fontSize: ScUtil().setSp(14),
                                          letterSpacing: -0.2,
                                          color: FitnessAppTheme.grey
                                              .withOpacity(0.5),
                                        ),
                                        ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          )
                          // Covered Card ends
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              // child: Card(
              //   shape: RoundedRectangleBorder(
              //     borderRadius: BorderRadius.all(
              //       Radius.circular(15),
              //     ),
              //   ),
              //   // color: Color.fromRGBO(35, 107, 254, 0.8),
              //   color: Colors.transparent,
              //   child: Column(
              //     crossAxisAlignment: CrossAxisAlignment.center,
              //     // mainAxisAlignment: MainAxisAlignment.center,
              //     children: [
              //       // SizedBox(
              //       //   height: 8.0,
              //       // ),
              //       Center(
              //         child: Text(
              //           // 'Persistent Marathon Challenge',
              //           '$eventName',
              //           style: TextStyle(
              //               color: Colors.white,
              //               fontSize: ScUtil().setSp(14),
              //               fontWeight: FontWeight.w600,
              //               letterSpacing: 1.0,
              //               height: 3),
              //         ),
              //       ),
              //       Visibility(
              //         // visible: !(DateTime.now().compareTo(eve_date_form)>=0)&&!isUserEnrolled,
              //         visible: widget.userEnrolledMap['event_status'] == null ||
              //             widget.userEnrolledMap['event_status'] == 'enrolled',
              //         child: Center(
              //           child: Text(
              //             // 'Date: 9th Janaury 2022',
              //             'Date: $eventDate',
              //             style: TextStyle(
              //                 color: Colors.white,
              //                 fontSize: ScUtil().setSp(14),
              //                 fontWeight: FontWeight.w600,
              //                 letterSpacing: 0.5,
              //                 height: 3),
              //           ),
              //         ),
              //       ),
              //
              //       // Visibility(
              //       //   visible: statusText() != 'stop' || statusText() != 'complete',
              //       //   child: Padding(
              //       //     padding: const EdgeInsets.only(top: 10.0),
              //       //     child: ElevatedButton(
              //       //       style: ElevatedButton.styleFrom(
              //       //         shape: RoundedRectangleBorder(
              //       //           borderRadius: BorderRadius.circular(20.0),
              //       //         ),
              //       //         primary: Colors.black.withOpacity(0.7),
              //       //         textStyle: TextStyle(
              //       //             fontSize: 16, fontWeight: FontWeight.bold),
              //       //       ),
              //       //       // onPressed: () {
              //       //       //   if (isUserEnrolled == false) {
              //       //       //     Get.to(
              //       //       //       MarathonDetails( indexed:widget.indexx,
              //       //       //         img: eventImg,
              //       //       //         description: eventDescription,
              //       //       //         name: eventName,
              //       //       //         start: false,
              //       //       //         eventDetailList: widget.eventDetailList,
              //       //       //       ),
              //       //       //     );
              //       //       //   } else {
              //       //       //     Get.to(
              //       //       //       MarathonDetails( indexed:widget.indexx,
              //       //       //         img: eventImg,
              //       //       //         description: eventDescription,
              //       //       //         name: eventName,
              //       //       //         start: true,
              //       //       //         eventDetailList: widget.eventDetailList,
              //       //       //       ),
              //       //       //     );}},
              //       //       child: Text(
              //       //         // isUserEnrolled == false ? 'Enroll Me' : status==null? 'Start': status==''completed'?'ccc',
              //       //         isUserEnrolled == true ? statusText() : 'Enroll Me',
              //       //         style: TextStyle(
              //       //             color: Colors.white,
              //       //             letterSpacing: 1.5,
              //       //             fontSize: ScUtil().setSp(14)),
              //       //       ),
              //       //     ),
              //       //   ),
              //       // ),
              //
              //       Visibility(
              //         // visible: (DateTime.now().compareTo(eve_date_form)<=0),
              //         child: Padding(
              //           padding: const EdgeInsets.only(top: 10.0),
              //           child: ElevatedButton(
              //             style: ElevatedButton.styleFrom(
              //               shape: RoundedRectangleBorder(
              //                 borderRadius: BorderRadius.circular(20.0),
              //               ),
              //               primary: Colors.black.withOpacity(0.7),
              //               textStyle: TextStyle(
              //                   fontSize: 16, fontWeight: FontWeight.bold),
              //             ),
              //             // onPressed: () {
              //             //   if (isUserEnrolled == false) {
              //             //     Get.to(
              //             //       MarathonDetails( indexed:widget.indexx,
              //             //         img: eventImg,
              //             //         description: eventDescription,
              //             //         name: eventName,
              //             //         start: false,
              //             //         eventDetailList: widget.eventDetailList,
              //             //       ),
              //             //     );
              //             //   } else {
              //             //     Get.to(
              //             //       MarathonDetails( indexed:widget.indexx,
              //             //         img: eventImg,
              //             //         description: eventDescription,
              //             //         name: eventName,
              //             //         start: true,
              //             //         eventDetailList: widget.eventDetailList,
              //             //       ),
              //             //     );}},
              //             child: DateTime.now().isBefore(event_end_date)
              //                 ? Text(
              //                     // isUserEnrolled == false ? 'Enroll Me' : status==null? 'Start': status==''completed'?'ccc',
              //                     isUserEnrolled == true
              //                         ? statusText()
              //                         : 'Enroll Me',
              //                     style: TextStyle(
              //                         color: Colors.white,
              //                         letterSpacing: 1.5,
              //                         fontSize: ScUtil().setSp(14)),
              //                   )
              //                 : Text(
              //                     // isUserEnrolled == false ? 'Enroll Me' : status==null? 'Start': status==''completed'?'ccc',
              //                     'Expired',
              //                     style: TextStyle(
              //                         color: Colors.white,
              //                         letterSpacing: 1.5,
              //                         fontSize: ScUtil().setSp(14)),
              //                   ),
              //           ),
              //         ),
              //       ),
              //       SizedBox(
              //         height: ScUtil().setHeight(10),
              //       ),
              //
              //       Visibility(
              //         // visible: false,
              //         visible: widget.userEnrolledMap['event_status'] != null &&
              //             widget.userEnrolledMap['event_status'] != 'enrolled',
              //         // visible: widget.userEnrolledMap['event_status']!=null&&widget.userEnrolledMap['event_status']!='enrolled'&&showFromSharedPref!=true,
              //         child: Container(
              //           width: MediaQuery.of(context).size.width,
              //
              //           //  width: ScUtil().setWidth(110),
              //           height: ScUtil().setHeight(60),
              //           child: showFromApi.value == false
              //               ? Row(
              //                   crossAxisAlignment: CrossAxisAlignment.center,
              //                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //                   children: [
              //                     /// Duration Card starts
              //                     Container(
              //                       // height: 80,
              //                       // width: 120,
              //                       width: ScUtil().setWidth(100),
              //                       height: ScUtil().setHeight(70),
              //                       child: Card(
              //                           child: Column(
              //                         mainAxisAlignment:
              //                             MainAxisAlignment.spaceEvenly,
              //                         children: [
              //                           Text(
              //                             'Duration',
              //                             style: TextStyle(
              //                               color: Colors.blueAccent,
              //                               letterSpacing: 1.5,
              //                               fontWeight: FontWeight.w600,
              //                               fontSize: ScUtil().setSp(14),
              //                             ),
              //                           ),
              //                           // RichText(
              //                           //   text: ValueListenableBuilder(
              //                           //     valueListenable: todaySteps,
              //                           //     builder: (context, value, widget) {
              //                           //       String v = value.toString();
              //                           //       if(value.toString().length<2){
              //                           //         v= '0'+value.toString();
              //                           //       }
              //                           //       return  Text();
              //                           //     },
              //                           //   ),
              //                           // ),
              //                           Row(
              //                               mainAxisAlignment:
              //                                   MainAxisAlignment.center,
              //                               children: [
              //                                 ValueListenableBuilder(
              //                                   // valueListenable: showFromApi.value==false?hoursStr:apiHoursStr,
              //                                   valueListenable: hoursStr,
              //                                   builder:
              //                                       (context, value, widget) {
              //                                     String v = value.toString();
              //                                     if (value.toString().length <
              //                                         2) {
              //                                       v = '0' + value.toString();
              //                                     }
              //                                     return Text(
              //                                       v.toString() + ":",
              //                                       style: TextStyle(
              //                                         color: Colors.black,
              //                                         letterSpacing: 1.5,
              //                                         fontWeight: FontWeight.w600,
              //                                         fontSize:
              //                                             ScUtil().setSp(14),
              //                                       ),
              //                                     );
              //                                   },
              //                                 ),
              //
              //                                 SizedBox(
              //                                   width: ScUtil().setWidth(1),
              //                                 ),
              //
              //                                 ValueListenableBuilder(
              //                                   valueListenable: minutesStr,
              //                                   builder:
              //                                       (context, value, widget) {
              //                                     String v = value.toString();
              //                                     print('Stream->Seconds =>>' +
              //                                         value.toString());
              //                                     if (value.toString().length <
              //                                         2) {
              //                                       v = '0' + value.toString();
              //                                     }
              //
              //                                     return Text(
              //                                       v.toString() + ":",
              //                                       style: TextStyle(
              //                                         color: Colors.black,
              //                                         letterSpacing: 1.5,
              //                                         fontWeight: FontWeight.w600,
              //                                         fontSize:
              //                                             ScUtil().setSp(14),
              //                                       ),
              //                                     );
              //                                   },
              //                                 ),
              //
              //                                 SizedBox(
              //                                   width: ScUtil().setWidth(1),
              //                                 ),
              //                                 ValueListenableBuilder(
              //                                   valueListenable: secondsStr,
              //                                   builder:
              //                                       (context, value, widget) {
              //                                     String v = value.toString();
              //                                     if (value.toString().length <
              //                                         2) {
              //                                       v = '0' + value.toString();
              //                                     }
              //
              //                                     return Text(
              //                                       v.toString(),
              //                                       style: TextStyle(
              //                                         color: Colors.black,
              //                                         letterSpacing: 1.5,
              //                                         fontWeight: FontWeight.w600,
              //                                         fontSize:
              //                                             ScUtil().setSp(14),
              //                                       ),
              //                                     );
              //                                   },
              //                                 ),
              //
              //                                 // buildTimeCard(time: minutesStr.toString(), header:'MINUTES'),
              //                                 // SizedBox(width: ScUtil().setWidth(15),),
              //                                 // buildTimeCard(time: secondsStr.toString(), header:'SECONDS'),
              //                               ]),
              //                         ],
              //                       )),
              //                     ),
              //                     // Duration Card ends
              //
              //                     // Remaining Card starts
              //                     Visibility(
              //                       // visible: false,
              //                       visible:
              //                           widget.userEnrolledMap['event_status'] !=
              //                               'pause',
              //                       child: Container(
              //                         width: ScUtil().setWidth(100),
              //                         height: ScUtil().setHeight(70),
              //                         child: Card(
              //                             child: Column(
              //                           mainAxisAlignment:
              //                               MainAxisAlignment.spaceEvenly,
              //                           children: [
              //                             Text(
              //                               'Remaining',
              //                               style: TextStyle(
              //                                 color: Colors.blueAccent,
              //                                 letterSpacing: 1.5,
              //                                 fontWeight: FontWeight.w600,
              //                                 fontSize: ScUtil().setSp(14),
              //                               ),
              //                               // style: TextStyle(
              //                               //     color: Colors.blueAccent,
              //                               //     letterSpacing: 0.7,
              //                               //     fontWeight: FontWeight.w600,
              //                               //     fontSize: ScUtil().setSp(17)),
              //                             ),
              //                             ValueListenableBuilder(
              //                               valueListenable: todaySteps,
              //                               builder: (context, value, widget) {
              //                                 String v = value.toString();
              //                                 // if(value.toString().length<2){
              //                                 //   v= STR.kms(steps: value.toString()).toString();
              //                                 // }
              //
              //                                 return Text(
              //                                   "${(totalDistance - STR.kmsWithSteps(steps: value.toString())).toStringAsFixed(2)} KM",
              //                                   style: TextStyle(
              //                                     color: Colors.black,
              //                                     letterSpacing: 1.5,
              //                                     fontWeight: FontWeight.w600,
              //                                     fontSize: ScUtil().setSp(14),
              //                                   ),
              //                                 );
              //                               },
              //                             ),
              //                             // Text(
              //                             //   // '2.03 KM',
              //                             //   "${totalDistance - STR.kms(steps: widget.userEnrolledMap['steps'])!=null?STR.kms(steps: widget.userEnrolledMap['steps']):0} KM",
              //                             //   style: TextStyle(
              //                             //     color: Colors.black,
              //                             //     letterSpacing: 1.5,
              //                             //     fontWeight: FontWeight.w600,
              //                             //     fontSize: ScUtil().setSp(14),
              //                             //   ),
              //                             // ),
              //                           ],
              //                         )),
              //                       ),
              //                     ),
              //                     Visibility(
              //                       visible:
              //                           widget.userEnrolledMap['event_status'] ==
              //                               'pause',
              //                       child: FloatingActionButton(
              //                         backgroundColor: Colors.white,
              //                         child: Icon(
              //                           Icons.play_arrow,
              //                           color: Colors.blue,
              //                           size: 35,
              //                         ),
              //                         elevation: 200,
              //                         onPressed: () async {
              //                           setState(() {
              //                             pauseValue = true;
              //                           });
              //                           // widget.userEnrolledMap['event_status'] = 'resume';
              //                           // STR.startt('resume',widget.eventDetailList[widget.indexx]['event_id']);
              //                           // STR.initPlatformState();
              //                           checkPermission1(
              //                               event_status: 'resume',
              //                               event_id: widget.eventDetailList[
              //                                   widget.indexx]['event_id']);
              //                         },
              //                       ),
              //                     ),
              //
              //                     Container(
              //                       width: ScUtil().setWidth(100),
              //                       height: ScUtil().setHeight(70),
              //                       child: Card(
              //                         child: Column(
              //                           mainAxisAlignment:
              //                               MainAxisAlignment.spaceEvenly,
              //                           children: [
              //                             Text(
              //                               'Covered',
              //                               style: TextStyle(
              //                                 color: Colors.blueAccent,
              //                                 letterSpacing: 1.5,
              //                                 fontWeight: FontWeight.w600,
              //                                 fontSize: ScUtil().setSp(14),
              //                               ),
              //                             ),
              //                             ValueListenableBuilder(
              //                               valueListenable: todaySteps,
              //                               builder: (context, value, widget) {
              //                                 String v = value.toString();
              //                                 // if(value.toString().length<2){
              //                                 //   v= STR.kms(steps: value.toString()).toString();
              //                                 // }
              //
              //                                 return Text(
              //                                   // "${STR.kmsWithSteps(steps: value.toString())} KM", style: TextStyle(
              //                                   STR
              //                                               .kmsWithSteps(
              //                                                   steps: value
              //                                                       .toString())
              //                                               .toString()
              //                                               .length <
              //                                           4
              //                                       ? "${STR.kmsWithSteps(steps: value.toString())}0 KM"
              //                                       : "${STR.kmsWithSteps(steps: value.toString())} KM",
              //                                   style: TextStyle(
              //                                     color: Colors.black,
              //                                     letterSpacing: 1.5,
              //                                     fontWeight: FontWeight.w600,
              //                                     fontSize: ScUtil().setSp(14),
              //                                   ),
              //                                 );
              //                               },
              //                             ),
              //                             // Text(
              //                             //   // '7.97 KM',
              //                             //   "${STR.kms(steps: todaySteps.value.toString())} KM",
              //                             //   style: TextStyle(
              //                             //     color: Colors.black,
              //                             //     letterSpacing: 1.5,
              //                             //     fontWeight: FontWeight.w600,
              //                             //     fontSize: ScUtil().setSp(14),
              //                             //   ),
              //                             // )
              //                           ],
              //                         ),
              //                       ),
              //                     )
              //                     // Covered Card ends
              //                   ],
              //                 )
              //               : Row(
              //                   crossAxisAlignment: CrossAxisAlignment.center,
              //                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //                   children: [
              //                     /// Duration Card starts
              //                     Container(
              //                       // height: 80,
              //                       // width: 120,
              //                       width: ScUtil().setWidth(100),
              //                       height: ScUtil().setHeight(70),
              //                       child: Card(
              //                           child: Column(
              //                         mainAxisAlignment:
              //                             MainAxisAlignment.spaceEvenly,
              //                         children: [
              //                           Text(
              //                             'Duration',
              //                             style: TextStyle(
              //                               color: Colors.blueAccent,
              //                               letterSpacing: 1.5,
              //                               fontWeight: FontWeight.w600,
              //                               fontSize: ScUtil().setSp(14),
              //                             ),
              //                           ),
              //                           Row(
              //                               mainAxisAlignment:
              //                                   MainAxisAlignment.center,
              //                               children: [
              //                                 ValueListenableBuilder(
              //                                   // valueListenable: showFromApi.value==false?hoursStr:apiHoursStr,
              //                                   valueListenable: apiHoursStr,
              //                                   builder:
              //                                       (context, value, widget) {
              //                                     String v = value.toString();
              //                                     if (value.toString().length <
              //                                         2) {
              //                                       v = '0' + value.toString();
              //                                     }
              //                                     return Text(
              //                                       v.toString() + ":",
              //                                       style: TextStyle(
              //                                         color: Colors.black,
              //                                         letterSpacing: 1.5,
              //                                         fontWeight: FontWeight.w600,
              //                                         fontSize:
              //                                             ScUtil().setSp(14),
              //                                       ),
              //                                     );
              //                                   },
              //                                 ),
              //
              //                                 SizedBox(
              //                                   width: ScUtil().setWidth(1),
              //                                 ),
              //
              //                                 ValueListenableBuilder(
              //                                   valueListenable: apiMinutesStr,
              //                                   builder:
              //                                       (context, value, widget) {
              //                                     String v = value.toString();
              //                                     if (value.toString().length <
              //                                         2) {
              //                                       v = '0' + value.toString();
              //                                     }
              //
              //                                     return Text(
              //                                       v.toString() + ":",
              //                                       style: TextStyle(
              //                                         color: Colors.black,
              //                                         letterSpacing: 1.5,
              //                                         fontWeight: FontWeight.w600,
              //                                         fontSize:
              //                                             ScUtil().setSp(14),
              //                                       ),
              //                                     );
              //                                   },
              //                                 ),
              //
              //                                 SizedBox(
              //                                   width: ScUtil().setWidth(1),
              //                                 ),
              //                                 ValueListenableBuilder(
              //                                   valueListenable: apiSecondsStr,
              //                                   builder:
              //                                       (context, value, widget) {
              //                                     String v = value.toString();
              //                                     if (value.toString().length <
              //                                         2) {
              //                                       v = '0' + value.toString();
              //                                     }
              //
              //                                     return Text(
              //                                       v.toString(),
              //                                       style: TextStyle(
              //                                         color: Colors.black,
              //                                         letterSpacing: 1.5,
              //                                         fontWeight: FontWeight.w600,
              //                                         fontSize:
              //                                             ScUtil().setSp(14),
              //                                       ),
              //                                     );
              //                                   },
              //                                 ),
              //
              //                                 // buildTimeCard(time: minutesStr.toString(), header:'MINUTES'),
              //                                 // SizedBox(width: ScUtil().setWidth(15),),
              //                                 // buildTimeCard(time: secondsStr.toString(), header:'SECONDS'),
              //                               ]),
              //                         ],
              //                       )),
              //                     ),
              //                     // Duration Card ends
              //
              //                     // Remaining Card starts
              //                     Visibility(
              //                       // visible: false,
              //                       visible:
              //                           widget.userEnrolledMap['event_status'] !=
              //                               'pause',
              //                       child: Container(
              //                         width: ScUtil().setWidth(100),
              //                         height: ScUtil().setHeight(70),
              //                         child: Card(
              //                             child: Column(
              //                           mainAxisAlignment:
              //                               MainAxisAlignment.spaceEvenly,
              //                           children: [
              //                             Text(
              //                               'Remaining',
              //                               style: TextStyle(
              //                                 color: Colors.blueAccent,
              //                                 letterSpacing: 1.5,
              //                                 fontWeight: FontWeight.w600,
              //                                 fontSize: ScUtil().setSp(14),
              //                               ),
              //                               // style: TextStyle(
              //                               //     color: Colors.blueAccent,
              //                               //     letterSpacing: 0.7,
              //                               //     fontWeight: FontWeight.w600,
              //                               //     fontSize: ScUtil().setSp(17)),
              //                             ),
              //                             Text(
              //                               // '2.03 KM',
              //                               "${(totalDistance - STR.kmsWithSteps(steps: apiTodaySteps.value)).toStringAsFixed(2)} KM",
              //                               style: TextStyle(
              //                                 color: Colors.black,
              //                                 letterSpacing: 1.5,
              //                                 fontWeight: FontWeight.w600,
              //                                 fontSize: ScUtil().setSp(14),
              //                               ),
              //                             ),
              //                           ],
              //                         )),
              //                       ),
              //                     ),
              //                     Visibility(
              //                       visible:
              //                           widget.userEnrolledMap['event_status'] ==
              //                               'pause',
              //                       child: FloatingActionButton(
              //                         backgroundColor: Colors.white,
              //                         child: Icon(
              //                           Icons.play_arrow,
              //                           color: Colors.blue,
              //                           size: 35,
              //                         ),
              //                         elevation: 200,
              //                         onPressed: () {
              //                           setState(() {
              //                             pauseValue = true;
              //                           });
              //                           checkPermission2(
              //                               event_id: widget.eventDetailList[
              //                                   widget.indexx]['event_id'],
              //                               event_status: 'resume');
              //                         },
              //                       ),
              //                     ),
              //
              //                     Container(
              //                       width: ScUtil().setWidth(100),
              //                       height: ScUtil().setHeight(70),
              //                       child: Card(
              //                         child: Column(
              //                           mainAxisAlignment:
              //                               MainAxisAlignment.spaceEvenly,
              //                           children: [
              //                             Text(
              //                               'Covered',
              //                               style: TextStyle(
              //                                 color: Colors.blueAccent,
              //                                 letterSpacing: 1.5,
              //                                 fontWeight: FontWeight.w600,
              //                                 fontSize: ScUtil().setSp(14),
              //                               ),
              //                             ),
              //                             Text(
              //                               // '7.97 KM',
              //                               // "${STR.kmsWithSteps(steps: apiTodaySteps.value.toString())} KM",
              //                               // STR.kmsWithSteps(steps: value.toString()).toString().length<4?"${STR.kmsWithSteps(steps: value.toString())}0 KM":"${STR.kmsWithSteps(steps: value.toString())} KM", style: TextStyle(
              //
              //                               STR
              //                                           .kmsWithSteps(
              //                                               steps: apiTodaySteps
              //                                                   .value
              //                                                   .toString())
              //                                           .toString()
              //                                           .length <
              //                                       4
              //                                   ? "${STR.kmsWithSteps(steps: apiTodaySteps.value.toString())}0 KM"
              //                                   : "${STR.kmsWithSteps(steps: apiTodaySteps.value.toString())} KM",
              //                               style: TextStyle(
              //                                 color: Colors.black,
              //                                 letterSpacing: 1.5,
              //                                 fontWeight: FontWeight.w600,
              //                                 fontSize: ScUtil().setSp(14),
              //                               ),
              //                             )
              //                           ],
              //                         ),
              //                       ),
              //                     )
              //                     // Covered Card ends
              //                   ],
              //                 ),
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
            ),
          ),
        );
      } else {
        return GestureDetector(
          onTap: () {
            // if (isUserEnrolled == true) {
            usingOtherAppOnTap();
          },
          child: Padding(
            padding: EdgeInsets.only(
                left: ScUtil().setWidth(4),
                right: ScUtil().setWidth(4),
                top: ScUtil().setHeight(16),
                bottom: ScUtil().setHeight(18)),
            child: Container(
              // margin: EdgeInsets.only(bottom: ScUtil().setHeight(8)),
              // height: MediaQuery.of(context).size.height / 2.9,
              width: MediaQuery.of(context).size.width,
              //  width: ScUtil().setWidth(110),
              // height: ScUtil().setHeight(20),
              // decoration: BoxDecoration(
              //   borderRadius: BorderRadius.circular(20),
              //   image: DecorationImage(
              //       image: AssetImage(
              //         'assets/images/marathon3.jpg',
              //       ),
              //       fit: BoxFit.cover),
              // ),
              ///asdfghjk
              decoration: BoxDecoration(
                color: FitnessAppTheme.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8.0),
                    bottomLeft: Radius.circular(8.0),
                    bottomRight: Radius.circular(8.0),
                    topRight: Radius.circular(68.0)),
                // image: DecorationImage(
                //     image: AssetImage(
                //       'assets/images/marathon3.jpg',
                //     ),
                //     fit: BoxFit.cover),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                      color: FitnessAppTheme.grey.withOpacity(0.2),
                      // color: FitnessAppTheme.nea,
                      offset: Offset(1.1, 1.1),
                      blurRadius: 10.0),
                ],
              ),
              ///asdfghjk
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                // mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: ScUtil().setWidth(12)),
                    child: Center(
                      child: Text(
                        // 'Persistent one Marathon Challenge',
                        '$eventName',
                        softWrap: true,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: FitnessAppTheme.grey,
                            fontSize: ScUtil().setSp(14),
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.0,
                            height: 3),
                      ),
                    ),
                  ),
                  Visibility(
                    // visible: !(DateTime.now().compareTo(eve_date_form)>=0)&&!isUserEnrolled,
                    visible: widget.userEnrolledMap['event_status'] == null ||
                        widget.userEnrolledMap['event_status'] == 'enrolled',
                    child: Center(
                      child: Text(
                        // 'Date: 9th Janaury 2022',
                        'Date: $eventDate',
                        style: TextStyle(
                            color: AppColors.primaryAccentColor,
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
                          // primary: Colors.black.withOpacity(0.7),
                          primary: DateTime.now().isBefore(event_end_date) ? AppColors.primaryAccentColor:Colors.grey,
                          textStyle: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        onPressed: (){
                          ///only write for testing...
                          usingOtherAppOnTap();
                          // Get.to(
                          //   MarathonDetails(
                          //     indexed: widget.indexx,
                          //     img: eventImg,
                          //     description: eventDescription,
                          //     name: eventName,
                          //     start: false,
                          //     eventDetailList: widget.eventDetailList,
                          //     userEnrolledMap: widget.userEnrolledMap,
                          //   ),
                          // );
                        },
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
                ],
              ),
            ),
          ),
        );
      }
    } else {
      return CircularProgressIndicator();
    }
  }

  checkPermission1({event_status, event_id}) async {
    // await Permission.activityRecognition.request();
    var status = await Permission.activityRecognition.status;
    if (status.isGranted) {
      // await STR.startt('$event_status', widget.eventDetailList[widget.indexx]['event_id']);
      await STR.startt('$event_status', event_id);
      await STR.initPlatformState();
      if (isUserEnrolled == false) {
        Get.to(
          MarathonDetails(
            indexed: widget.indexx,
            img: eventImg,
            description: eventDescription,
            name: eventName,
            start: false,
            eventDetailList: widget.eventDetailList,
            userEnrolledMap: widget.userEnrolledMap,
          ),
        );
      } else {
        Get.to(
          MarathonDetails(
            indexed: widget.indexx,
            img: eventImg,
            description: eventDescription,
            name: eventName,
            start: true,
            eventDetailList: widget.eventDetailList,
            userEnrolledMap: widget.userEnrolledMap,
            pauseOrResume: true,
          ),
        );
      }
    } else if (status.isDenied) {
      await Permission.activityRecognition.request();
      status = await Permission.activityRecognition.status;
      if (status.isGranted) {
        await STR.startt('$event_status', event_id);
        await STR.initPlatformState();
        if (isUserEnrolled == false) {
          Get.to(
            MarathonDetails(
              indexed: widget.indexx,
              img: eventImg,
              description: eventDescription,
              name: eventName,
              start: false,
              eventDetailList: widget.eventDetailList,
              userEnrolledMap: widget.userEnrolledMap,
            ),
          );
        } else {
          Get.to(
            MarathonDetails(
              indexed: widget.indexx,
              img: eventImg,
              description: eventDescription,
              name: eventName,
              start: true,
              eventDetailList: widget.eventDetailList,
              userEnrolledMap: widget.userEnrolledMap,
              pauseOrResume: true,
            ),
          );
        }
      } else {
        Get.snackbar(
            'Activity Access Denied', 'Allow Activity permission to continue',
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
      Get.snackbar(
          'Activity Access Denied', 'Allow Activity permission to continue',
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

  checkPermission2({event_status, event_id}) async {
    // await Permission.activityRecognition.request();
    var status = await Permission.activityRecognition.status;
    if (status.isGranted) {
      // await STR.startt('$event_status', widget.eventDetailList[widget.indexx]['event_id']);
      await STR.startt('$event_status', event_id);
      await STR.initPlatformState();
      if (isUserEnrolled == false) {
        Get.to(
          MarathonDetails(
            indexed: widget.indexx,
            img: eventImg,
            description: eventDescription,
            name: eventName,
            start: false,
            eventDetailList: widget.eventDetailList,
            userEnrolledMap: widget.userEnrolledMap,
          ),
        );
      } else {
        Get.to(
          MarathonDetails(
            indexed: widget.indexx,
            img: eventImg,
            description: eventDescription,
            name: eventName,
            start: true,
            eventDetailList: widget.eventDetailList,
            userEnrolledMap: widget.userEnrolledMap,
            pauseOrResume: true,
          ),
        );
      }
    } else if (status.isDenied) {
      await Permission.activityRecognition.request();
      status = await Permission.activityRecognition.status;
      if (status.isGranted) {
        await STR.startt('$event_status', event_id);
        await STR.initPlatformState();
        if (isUserEnrolled == false) {
          Get.to(
            MarathonDetails(
              indexed: widget.indexx,
              img: eventImg,
              description: eventDescription,
              name: eventName,
              start: false,
              eventDetailList: widget.eventDetailList,
              userEnrolledMap: widget.userEnrolledMap,
            ),
          );
        } else {
          Get.to(
            MarathonDetails(
              indexed: widget.indexx,
              img: eventImg,
              description: eventDescription,
              name: eventName,
              start: true,
              eventDetailList: widget.eventDetailList,
              userEnrolledMap: widget.userEnrolledMap,
              pauseOrResume: true,
            ),
          );
        }
      } else {
        Get.snackbar(
            'Activity Access Denied', 'Allow Activity permission to continue',
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
      Get.snackbar(
          'Activity Access Denied', 'Allow Activity permission to continue',
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
  checkPermissionFullCard() async {
    // await Permission.activityRecognition.request();
    var status = Platform.isAndroid ?await Permission.activityRecognition.status:await Permission.sensors.status;
    if (status.isGranted) {
      ///here
      Get.to(
        MarathonDetails(
          indexed: widget.indexx,
          img: eventImg,
          description: eventDescription,
          name: eventName,
          start: true,
          eventDetailList: widget.eventDetailList,
          userEnrolledMap: widget.userEnrolledMap,
        ),
      );
    } else if (status.isDenied) {
      Platform.isAndroid ?await Permission.activityRecognition.request():await Permission.sensors.request();
      status = Platform.isAndroid ? await Permission.activityRecognition.status:await Permission.sensors.status;
      if (status.isGranted) {
        ///here
        Get.to(
          MarathonDetails(
            indexed: widget.indexx,
            img: eventImg,
            description: eventDescription,
            name: eventName,
            start: true,
            eventDetailList: widget.eventDetailList,
            userEnrolledMap: widget.userEnrolledMap,
          ),
        );
      } else {
        showDialog(
            context: context,
            builder: (BuildContext context) =>CupertinoAlertDialog(
              title: new Text("Activity Access Denied"),
              content: new Text("Allow Activity permission to continue"),
              actions: <Widget>[
                CupertinoDialogAction(
                  isDefaultAction: true,
                  child: Text("Yes"),
                  onPressed: () async {
                    await openAppSettings();
                    Get.back();
                  },
                ),
                CupertinoDialogAction(
                  child: Text("No"),
                  onPressed: ()=>Get.back(),
                )
              ],
            ))  ;
      }
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) =>CupertinoAlertDialog(
            title: new Text("Activity Access Denied"),
            content: new Text("Allow Activity permission to continue"),
            actions: <Widget>[
              CupertinoDialogAction(
                isDefaultAction: true,
                child: Text("Yes"),
                onPressed: () async {
                  await openAppSettings();
                  Get.back();
                },
              ),
              CupertinoDialogAction(
                child: Text("No"),
                onPressed: ()=>Get.back(),
              )
            ],
          ))  ;
      // Get.snackbar(
      //     'Activity Access Denied', 'Allow Activity permission to continue',
      //     backgroundColor: Colors.red,
      //     colorText: Colors.white,
      //     duration: Duration(seconds: 5),
      //     isDismissible: false,
      //     mainButton: TextButton(
      //         onPressed: () async {
      //           await openAppSettings();
      //         },
      //         child: Text('Allow')));
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
