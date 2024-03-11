import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectanum/connectanum.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ihl/new_design/app/utils/appColors.dart';
import 'package:ihl/new_design/presentation/pages/dashboard/common_screen_for_navigation.dart';
import 'package:ihl/views/teleconsultation/appointment_status_check.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:strings/strings.dart';

import '../../../../cardio_dashboard/controllers/controller_for_cardio.dart';
import '../../../../constants/api.dart';
import '../../../../models/appointment_pagination_model.dart';
import '../../../../tabs/profiletab.dart';
import '../../../../utils/dateFormat.dart';
import '../../../data/model/TeleconsultationModels/appointmentTimings.dart';
import '../../../data/model/TeleconsultationModels/doctorModel.dart';
import '../../clippath/subscriptionTagClipPath.dart';
import '../../controllers/dashboardControllers/dashBoardContollers.dart';
import '../../controllers/teleconsultation_onlineServices/teleconsultation_apiCalls.dart';
import '../../controllers/teleconsultation_onlineServices/teleconsultation_functions.dart';
import '../basicData/functionalities/percentage_calculations.dart';
import '../dashboard/affiliation_dashboard/affiliationDasboard.dart';
import 'confirmVisitPage.dart';

class DoctorsDescriptionScreen extends StatefulWidget {
  DoctorsDescriptionScreen(
      {Key key,
      this.doctorDetails,
      this.ihlConsultantId,
      this.appointment_start_time,
      this.CallStatus})
      : super(key: key);
  DoctorModel doctorDetails;
  String ihlConsultantId;
  String CallStatus;
  String appointment_start_time;

  @override
  State<DoctorsDescriptionScreen> createState() => _DoctorsDescriptionScreenState();
}

class _DoctorsDescriptionScreenState extends State<DoctorsDescriptionScreen> {
  bool enableJoinCall = false;
  String status = 'Offline';
  Stream _stream;
  var appointmentStartingTime;
  ScrollController _controller;
  Map a;
  List<AppointmentsTimings> alltimingList = [];
  int selectedIndex = 0;
  List val = [];
  DateTime _lastAppointmentTime = DateTime.now().subtract(Duration(minutes: 15));

  bool _callAllowed = false;

  @override
  void initState() {
    debugPrint(widget.doctorDetails.toString());
    consultantFee = widget.doctorDetails.consultationFees.toString();
    consultationFeesSetter();
    TeleConsultationFunctionsAndVariables.timingsList = [];
    TeleConsultationFunctionsAndVariables.selectedDateTile.value['selectedTile'] = 'Today';
    TeleConsultationFunctionsAndVariables.selectedDateTile.value['selectedCategory'] = null;
    TeleConsultationFunctionsAndVariables.selectedDateTile.value['time'] = null;
    asynctimeSlotfun();
    update();
    statusChecker();
  }

  String consultantFee = "0";
  consultationFeesSetter() {
    //Checking the consultants price ✅
    if (selectedAffiliationfromuniquenameDashboard != "" &&
        selectedAffiliationfromuniquenameDashboard != null) {
      for (AffilationArray e in widget.doctorDetails.affilationExcusiveData.affilationArray) {
        if (selectedAffiliationfromuniquenameDashboard == e.affilationUniqueName) {
          consultantFee = e.affilationPrice.toString();
        }
      }
    }
  }

  statusChecker() async {
    List<CharacterSummary> appointmentStatus = await AppointmentStatusChecker()
        .getConsultantLatestAppointments(
            consultId: widget.doctorDetails.ihlConsultantId.toString());
    if (appointmentStatus.length > 0) {
      if (DateTime.now().day ==
          DateFormat('yyyy-MM-dd hh:mm a')
              .parse(appointmentStatus[0].bookApointment.appointmentStartTime)
              .day) {
        _lastAppointmentTime = DateFormat('yyyy-MM-dd hh:mm a')
            .parse(appointmentStatus[0].bookApointment.appointmentStartTime);
        if (DateTime.now().difference(_lastAppointmentTime) < Duration(minutes: 30) &&
            widget.CallStatus == 'on_going') {
          _callAllowed = true;
        } else {
          _callAllowed = false;
        }
      }
    }
  }

  asynctimeSlotfun() async {
    // SharedPreferences prefs1 = await SharedPreferences.getInstance();
    // var data1 = prefs1.get('data');
    // Map res = jsonDecode(data1);
    // var iHLUserId = res['User']['id'];
    ///time slots
    await TeleConsultationFunctionsAndVariables.getAvailableSlotList(
        ihlConsultantID: widget.doctorDetails.ihlConsultantId,
        vendorID: widget.doctorDetails.vendorId);
    // Map userId = await CardioController().consultantDataList(userId: iHLUserId);
    // print(userId);
    // List consultationType = userId["consult_type"];
    // print(consultationType);
  }

  update() async {
    // String doctorId = widget.ihlConsultantId;
    try {
      _stream = FireStoreCollections.consultantOnlineStatus
          .doc(widget.doctorDetails.ihlConsultantId)
          .snapshots();
      // String appointmentStartstringTime = widget.appointment_start_time.substring(11, 19);
      // String appointmentStartTime = widget.appointment_start_time.substring(0, 10);
      // DateTime startTimeformattime = DateFormat.jm().parse(appointmentStartstringTime);
      // String starttime = DateFormat("HH:mm:ss").format(startTimeformattime);
      // String appointmentStartdateToFormat = appointmentStartTime + " " + starttime;
      // appointmentStartingTime = DateTime.parse(appointmentStartdateToFormat);
      // DateTime fiveMinutesBeforeStartAppointment =
      //     appointmentStartingTime.subtract(new Duration(minutes: 0));
      // DateTime thirtyMinutesAfterStartAppointment =
      //     appointmentStartingTime.add(new Duration(minutes: 30));
      // print(fiveMinutesBeforeStartAppointment);
      // print(thirtyMinutesAfterStartAppointment);
      // print(DateTime.now());
      // if (DateTime.now().isAfter(fiveMinutesBeforeStartAppointment) &&
      //     DateTime.now().isBefore(thirtyMinutesAfterStartAppointment) &&
      //     widget.CallStatus != "completed") {
      //   if (this.mounted) {
      //     setState(() {
      //       enableJoinCall = true;
      //     });
      //   }
      // }
    } on Abort catch (abort) {
      print(abort.message.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CommonScreenForNavigation(
      contentColor: '',
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () async {
            Get.back();
          }, //replaces the screen to Main dashboard
          color: Colors.white,
        ),
        centerTitle: true,
        title: const Text("Consultation"),
      ),
      content: ListView(
        children: <Widget>[
          Column(
            children: <Widget>[
              SizedBox(
                height: 1.h,
              ),
              SizedBox(
                width: 96.4.w,
                child: Card(
                  elevation: 4,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <
                            Widget>[
                          FutureBuilder<Uint8List>(
                            future: TeleConsultationFunctionsAndVariables.vendorImage(
                                vendorName: widget.doctorDetails.vendorId),
                            builder: (BuildContext context, AsyncSnapshot<Uint8List> i) {
                              if (i.connectionState == ConnectionState.done) {
                                return Container(
                                  width: 13.w,
                                  height: 6.w,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    image: DecorationImage(
                                      image: Image.memory(
                                        i.data,
                                      ).image,
                                    ),
                                  ),
                                );
                              } else if (i.connectionState == ConnectionState.waiting) {
                                return Shimmer.fromColors(
                                  baseColor: Colors.white,
                                  highlightColor: Colors.grey.withOpacity(0.3),
                                  direction: ShimmerDirection.ltr,
                                  child: Container(
                                    width: 13.w,
                                    height: 6.w,
                                    decoration: const BoxDecoration(color: Colors.white),
                                  ),
                                );
                              } else {
                                return SizedBox(
                                  width: 13.w,
                                  height: 6.w,
                                );
                              }
                            },
                          ),
                          Container(
                            height: 4.w,
                            width: 13.w,
                            child: RotationTransition(
                              turns: const AlwaysStoppedAnimation(180 / 360),
                              child: ClipPath(
                                  clipper: SubscriptionClipPath(),
                                  child: StreamBuilder<DocumentSnapshot>(
                                    stream: _stream,
                                    builder: (BuildContext context,
                                        AsyncSnapshot<DocumentSnapshot> snapshot) {
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return FutureBuilder(
                                            future: TeleConsultationApiCalls.consultantStatus(
                                                consultantID: widget.ihlConsultantId),
                                            builder: (BuildContext ctx, AsyncSnapshot data) {
                                              if (data.connectionState == ConnectionState.waiting) {
                                                return Container(
                                                    color: Colors.grey,
                                                    child: const FittedBox(
                                                      child: RotationTransition(
                                                        turns: AlwaysStoppedAnimation<double>(
                                                            180 / 360),
                                                        child: Text(
                                                          "Offline",
                                                          style: TextStyle(
                                                              color: Colors.white,
                                                              fontFamily: "Poppins"),
                                                        ),
                                                      ),
                                                    ));
                                              }
                                              return Container(
                                                color: data.data.toString().toLowerCase() ==
                                                        "offline"
                                                    ? Colors.grey
                                                    : data.data.toString().toLowerCase() == "online"
                                                        ? Colors.green
                                                        : Colors.red,
                                                child: FittedBox(
                                                  child: RotationTransition(
                                                    turns: const AlwaysStoppedAnimation(180 / 360),
                                                    child: Text(
                                                      data.data,
                                                      style: const TextStyle(
                                                          color: Colors.white,
                                                          fontFamily: "Poppins"),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            });
                                      }
                                      if (!snapshot.data.exists ?? true) {
                                        FireStoreCollections.consultantOnlineStatus
                                            .doc(widget.ihlConsultantId)
                                            .set({
                                          'consultantId': widget.ihlConsultantId,
                                          'status': "Offline"
                                        });
                                      }
                                      Map _data = snapshot.data.data() as Map;
                                      String status = "Offline";
                                      if (_data != null) {
                                        status = _data['status'];
                                      } else {
                                        print("Doc status doesn't exist");
                                      }
                                      return InkWell(
                                          onTap: () {
                                            //it's for checking purpose to change the firestore status of the consultant.🍙
                                            // FireStoreCollections.consultantOnlineStatus
                                            //     .doc(doc.ihlConsultantId)
                                            //     .set({
                                            //   'consultantId': doc.ihlConsultantId,
                                            //   'status': status == 'Online' ? "Offline" : "Online"
                                            // });
                                          },
                                          child: Container(
                                              color: status.toLowerCase() == "offline"
                                                  ? Colors.grey
                                                  : status.toLowerCase() == "online"
                                                      ? Colors.green
                                                      : Colors.red,
                                              child: FittedBox(
                                                child: RotationTransition(
                                                  turns: const AlwaysStoppedAnimation(180 / 360),
                                                  child: Text(
                                                    status,
                                                    style: const TextStyle(
                                                        color: Colors.white, fontFamily: "Poppins"),
                                                  ),
                                                ),
                                              )));
                                    },
                                  )),
                            ),
                          ),
                        ]),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
                          SizedBox(
                            width: 30.w,
                            height: 16.h,
                            child: FutureBuilder<String>(
                              future: TabBarController().getConsultantImageUrl(
                                  doctor: widget.doctorDetails.toJson() ?? {}),
                              builder: (BuildContext context, AsyncSnapshot<String> i) {
                                if (i.connectionState == ConnectionState.done) {
                                  widget.doctorDetails.docImage = i.data.toString();
                                  return Container(
                                    width: 30.w,
                                    height: 16.h,
                                    decoration: BoxDecoration(
                                      color: const Color(0xff7c94b6),
                                      borderRadius: const BorderRadius.all(Radius.circular(4.0)),
                                      image: DecorationImage(
                                          image: Image.memory(
                                            base64Decode(
                                              i.data.toString(),
                                            ),
                                          ).image,
                                          fit: BoxFit.cover),
                                    ),
                                  );
                                } else if (i.connectionState == ConnectionState.waiting) {
                                  return Shimmer.fromColors(
                                    baseColor: Colors.white,
                                    highlightColor: Colors.grey.withOpacity(0.3),
                                    direction: ShimmerDirection.ltr,
                                    child: Container(
                                      width: 30.w,
                                      height: 16.h,
                                      decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                          bottomRight: Radius.circular(8.0),
                                          bottomLeft: Radius.circular(8.0),
                                          topLeft: Radius.circular(8.0),
                                          topRight: Radius.circular(8.0),
                                        ),
                                        color: Colors.white,
                                      ),
                                    ),
                                  );
                                } else {
                                  return SizedBox(width: 18.w, height: 18.w);
                                }
                              },
                            ),
                          ),
                          SizedBox(
                            width: 4.w,
                          ),
                          Container(
                            width: 56.w,
                            // height: 19.h,
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
                                Widget>[
                              Padding(
                                padding: const EdgeInsets.only(left: 4.0, bottom: 4.0),
                                child: FittedBox(
                                  child: Text(
                                    widget.doctorDetails.qualification == null
                                        ? widget.doctorDetails.name.toString()
                                        : widget.doctorDetails.name
                                            .toString()
                                            .replaceAll(widget.doctorDetails.qualification, ''),
                                    // maxLines: 1,
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
                                  ),
                                ),
                              ),
                              widget.doctorDetails.qualification == null
                                  ? const Text('')
                                  : Padding(
                                      padding: const EdgeInsets.only(left: 4.0, bottom: 4.0),
                                      child: Text(
                                        widget.doctorDetails.qualification.toString(),
                                        style:
                                            TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
                                      ),
                                    ),
                              Padding(
                                padding: const EdgeInsets.only(left: 4.0, bottom: 4.0),
                                child: Text(widget.doctorDetails.consultantSpeciality.join(' , ')),
                              ),
                              SizedBox(height: 2.h),
                              Row(
                                children: <Widget>[
                                  Visibility(
                                      visible: widget.doctorDetails.liveCallAllowed,
                                      child: StreamBuilder<DocumentSnapshot>(
                                        stream: _stream,
                                        builder: (BuildContext context,
                                            AsyncSnapshot<DocumentSnapshot> snapshot) {
                                          if (snapshot.connectionState == ConnectionState.waiting) {
                                            return FutureBuilder(
                                                future: TeleConsultationApiCalls.consultantStatus(
                                                    consultantID: widget.ihlConsultantId),
                                                builder: (BuildContext ctx, AsyncSnapshot data) {
                                                  if (data.connectionState ==
                                                      ConnectionState.waiting) {
                                                    return Container(
                                                      width: 8.w,
                                                      height: 9.w,
                                                      alignment: Alignment.center,
                                                      decoration: BoxDecoration(
                                                          shape: BoxShape.circle,
                                                          border: Border.all(color: Colors.grey),
                                                          color: Colors.grey),
                                                      child: const Icon(
                                                        Icons.call,
                                                        color: Colors.white,
                                                      ),
                                                    );
                                                  }
                                                  return Container(
                                                    width: 8.w,
                                                    height: 9.w,
                                                    alignment: Alignment.center,
                                                    decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        border: Border.all(
                                                            color: data.data
                                                                            .toString()
                                                                            .toLowerCase() ==
                                                                        "offline" &&
                                                                    !_callAllowed
                                                                ? Colors.grey
                                                                : AppColors.primaryColor),
                                                        color: data.data.toString().toLowerCase() ==
                                                                    "offline" &&
                                                                !_callAllowed
                                                            ? Colors.grey
                                                            : AppColors.primaryColor),
                                                    child: const Icon(
                                                      Icons.call,
                                                      color: Colors.white,
                                                    ),
                                                  );
                                                });
                                          }
                                          if (!snapshot.data.exists ?? true) {
                                            FireStoreCollections.consultantOnlineStatus
                                                .doc(widget.ihlConsultantId)
                                                .set({
                                              'consultantId': widget.ihlConsultantId,
                                              'status': "Offline"
                                            });
                                          }
                                          Map _data = snapshot.data.data() as Map;
                                          String status = "Offline";
                                          if (_data != null) {
                                            status = _data['status'];
                                          } else {
                                            print("Doc status doesn't exist");
                                          }
                                          return GestureDetector(
                                            onTap: status == 'Offline' ||
                                                    status.toLowerCase() == "busy"
                                                ? () {
                                                    debugPrint(
                                                        "Currently the consultant is $status");
                                                  }
                                                : PercentageCalculations()
                                                            .calculatePercentageFilled() !=
                                                        100
                                                    ? Get.to(ProfileTab(
                                                        editing: true,
                                                        bacNav: () {
                                                          Get.back();
                                                          // Get.to(ViewallTeleDashboard(
                                                          //   includeHelthEmarket: true,
                                                          // ));
                                                        }))
                                                    : () async {
                                                        final DateTime now = new DateTime.now();
                                                        String formattedDate =
                                                            DateFormat.yMMMMd('en_US').format(now);
                                                        String d_d = now.day.toString();
                                                        String m_m = now.month.toString();
                                                        m_m = MonthFormats
                                                            .month_number_to_String[m_m];
                                                        if (d_d.length == 1) {
                                                          d_d = '0' + d_d;
                                                        }
                                                        String y_y = now.year.toString();

                                                        String formattedTime = DateFormat("hh:mm a")
                                                            .format(DateTime.now());
                                                        formattedDate = d_d + 'th' + ' ' + m_m;
                                                        ValueNotifier<Map> selectedDateTile =
                                                            ValueNotifier({
                                                          "selectedTile": formattedDate,
                                                          "selectedCategory": "morning",
                                                          "time": formattedTime
                                                        });

                                                        SharedPreferences prefs =
                                                            await SharedPreferences.getInstance();
                                                        Object data = prefs.get('data');
                                                        Map res = jsonDecode(data);
                                                        Get.to(ConfirmVisitPage(
                                                            fees: consultantFee ?? '0',
                                                            liveCall: true,
                                                            doctorDetails: widget.doctorDetails,
                                                            datadecode: res,
                                                            slotSelectedTime:
                                                                selectedDateTile.value));
                                                      },
                                            child: Container(
                                              width: 9.w,
                                              height: 9.w,
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                      color: status.toLowerCase() == "offline" &&
                                                                  !_callAllowed ||
                                                              status.toLowerCase() == "busy"
                                                          ? Colors.grey
                                                          : AppColors.primaryColor),
                                                  color: status.toLowerCase() == "offline" &&
                                                              !_callAllowed ||
                                                          status.toLowerCase() == "busy"
                                                      ? Colors.grey
                                                      : AppColors.primaryColor),
                                              child: Icon(
                                                Icons.call,
                                                size: 18.sp,
                                                color: Colors.white,
                                              ),
                                            ),
                                          );
                                        },
                                      )),
                                  SizedBox(
                                    width: 6.w,
                                  ),
                                  Container(
                                    width: 8.w,
                                    height: 9.w,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(color: AppColors.primaryColor),
                                        color: AppColors.primaryColor),
                                    child: Icon(
                                      Icons.calendar_today_outlined,
                                      size: 18.sp,
                                      color: Colors.white,
                                    ),
                                  )
                                ],
                              )
                            ]),
                          ),
                        ]),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Column(
                            children: <Widget>[
                              Text(
                                'Experience',
                                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16.sp),
                              ),
                              Text(
                                widget.doctorDetails.experience,
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.sp),
                              ),
                            ],
                          ),
                          Column(
                            children: <Widget>[
                              Text(
                                'Rating',
                                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16.sp),
                              ),
                              Row(
                                children: <Widget>[
                                  Icon(
                                    Icons.star,
                                    color: AppColors.primaryColor,
                                    size: 15.px,
                                  ),
                                  Text(
                                    ' ${widget.doctorDetails.ratings}',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.sp),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Column(
                            children: <Widget>[
                              Text(
                                'Consultation Fee',
                                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16.sp),
                              ),
                              Row(
                                children: <Widget>[
                                  Text(
                                    '₹‎',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15.sp,
                                        color: AppColors.primaryColor),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(1.5),
                                    child: Text(
                                      consultantFee ?? '0',
                                      style: TextStyle(fontSize: 15.sp),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )
                        ],
                      ),
                      SizedBox(height: 10.sp)
                    ],
                  ),
                ),
              ),
              Visibility(
                visible: widget.doctorDetails.description.replaceAll('&#39;', "'") != "" &&
                    widget.doctorDetails.description.replaceAll('&#39;', "'") != "null",
                child: SizedBox(
                  width: 96.w,
                  child: Card(
                    elevation: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(left: 14.sp, top: 14.sp),
                          child: Text(
                            'Biography',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryColor,
                                fontSize: 17.sp),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(14.sp),
                          child: Text(widget.doctorDetails.description.replaceAll('&#39;', "'")),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              ValueListenableBuilder(
                  valueListenable: TeleConsultationFunctionsAndVariables.selectedDateTile,
                  builder: (BuildContext context, val1, Widget child) {
                    val = TeleConsultationFunctionsAndVariables.timingsList;
                    if (TeleConsultationFunctionsAndVariables.timingsList.isEmpty) {
                      return Shimmer.fromColors(
                        baseColor: Colors.white,
                        highlightColor: Colors.grey.withOpacity(0.3),
                        direction: ShimmerDirection.ltr,
                        child: Container(
                          width: 96.w,
                          height: 13.h,
                          decoration: const BoxDecoration(color: Colors.white),
                        ),
                      );
                    } else {
                      return
                          // TeleConsultationFunctionsAndVariables.getAvailableSlotList.
                          //   ? SizedBox():
                          Column(children: <Widget>[
                        Padding(
                          padding: EdgeInsets.all(18.sp),
                          child: Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
                            Text(
                              'Select Appointment Slot',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryColor,
                                  fontSize: 17.sp),
                            ),
                          ]),
                        ),
                        const SizedBox(
                          height: 4.0,
                        ),
                        SizedBox(
                          height: 12.h,
                          width: 96.w,
                          child: ListView.builder(
                            // controller: _controller,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (BuildContext ctx, int index) {
                              int _slot = 0;
                              String _mor = 'morning',
                                  _aft = 'afternoon',
                                  _eve = 'evening',
                                  _nig = 'night';
                              final DateTime _now = DateTime.now();
                              TimeOfDay t = TimeOfDay.now();
                              DateTime nowTime =
                                  DateTime(_now.year, _now.month, _now.day, t.hour, t.minute);
                              if (val[index].tileName == 'today') {
                                for (var time in val[index].categ.morning) {
                                  TimeOfDay tt = timeConvert(time);
                                  DateTime fromAPI =
                                      DateTime(_now.year, _now.month, _now.day, tt.hour, tt.minute);
                                  if (fromAPI.isAfter(nowTime)) {
                                    _slot++;
                                  }
                                }
                                // if (_now.hour < 12) _slot += e[key][0][_mor].length;
                              } else {
                                _slot += val[index].categ.morning.length;
                              }
                              if (val[index].tileName == 'today') {
                                for (var time in val[index].categ.afternoon) {
                                  TimeOfDay tt = timeConvert(time);
                                  DateTime fromAPI =
                                      DateTime(_now.year, _now.month, _now.day, tt.hour, tt.minute);
                                  if (fromAPI.isAfter(nowTime)) {
                                    _slot++;
                                  }
                                }
                                // if (_now.hour >= 12 && _now.hour < 17) _slot += e[key][0][_aft].length;
                              } else {
                                print('Not Today');
                                _slot += val[index].categ.afternoon.length;
                              }
                              // _tempList.add(e[key][0][_aft]);
                              if (val[index].tileName == 'today') {
                                val[index].categ.evening.forEach((time) {
                                  TimeOfDay tt = timeConvert(time);
                                  DateTime fromAPI =
                                      DateTime(_now.year, _now.month, _now.day, tt.hour, tt.minute);
                                  if (fromAPI.isAfter(nowTime)) {
                                    _slot++;
                                  }
                                });
                                // if (_now.hour >= 17 && _now.hour < 20) _slot += e[key][0][_eve].length;
                              } else {
                                print('Not Today');
                                _slot += val[index].categ.evening.length;
                              }
                              if (val[index].tileName == 'today') {
                                val[index].categ.night.forEach((time) {
                                  TimeOfDay tt = timeConvert(time);
                                  DateTime fromAPI =
                                      DateTime(_now.year, _now.month, _now.day, tt.hour, tt.minute);
                                  if (fromAPI.isAfter(nowTime)) {
                                    _slot++;
                                  }
                                });
                              } else {
                                _slot += val[index].categ.night.length;
                              }

                              return ValueListenableBuilder(
                                  valueListenable:
                                      TeleConsultationFunctionsAndVariables.selectedDateTile,
                                  builder: (BuildContext context, v, Widget child) {
                                    return Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: GestureDetector(
                                        onTap: _slot == 0
                                            ? () {}
                                            : () {
                                                TeleConsultationFunctionsAndVariables
                                                    .selectedDateTile.value['time'] = null;
                                                TeleConsultationFunctionsAndVariables
                                                    .selectedDateTile
                                                    .value['selectedTile'] = val[index].tileName;
                                                selectedIndex = val.indexWhere(
                                                    (e) => e.tileName == v["selectedTile"]);
                                                TeleConsultationFunctionsAndVariables
                                                    .selectedDateTile
                                                    .notifyListeners();
                                              },
                                        child: SizedBox(
                                          width: 36.w,
                                          child: Card(
                                            shape: (selectedIndex == 0 &&
                                                    _slot != 0 &&
                                                    val[index].tileName == "today")
                                                ? RoundedRectangleBorder(
                                                    side: const BorderSide(
                                                        color: AppColors.primaryColor, width: 2),
                                                    borderRadius: BorderRadius.circular(5))
                                                : (val.indexWhere((e) =>
                                                                e.tileName == v["selectedTile"]) ==
                                                            index &&
                                                        _slot != 0)
                                                    ? RoundedRectangleBorder(
                                                        side: const BorderSide(
                                                            color: AppColors.primaryColor,
                                                            width: 2),
                                                        borderRadius: BorderRadius.circular(5))
                                                    : RoundedRectangleBorder(
                                                        side: const BorderSide(
                                                            color: Colors.transparent, width: 2),
                                                        borderRadius: BorderRadius.circular(5)),
                                            elevation: 2,
                                            child: SizedBox(
                                              width: 36.w,
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                mainAxisSize: MainAxisSize.min,
                                                children: <Widget>[
                                                  _slot == 0
                                                      ? Text(
                                                          camelize(val[index].tileName),
                                                          style: TextStyle(
                                                              fontSize: 16.sp,
                                                              color: AppColors.primaryColor
                                                                  .withOpacity(0.5)),
                                                        )
                                                      : Text(
                                                          camelize(val[index].tileName),
                                                          style: TextStyle(
                                                              fontSize: 16.sp,
                                                              color: AppColors.primaryColor),
                                                        ),
                                                  _slot == 0
                                                      ? Text(
                                                          '$_slot Slots Available',
                                                          style: TextStyle(
                                                              fontSize: 15.sp,
                                                              color: Colors.black.withOpacity(0.5)),
                                                        )
                                                      : Text(
                                                          '$_slot Slots Available',
                                                          style: TextStyle(
                                                              fontSize: 15.sp, color: Colors.black),
                                                        ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  });
                            },
                            itemCount: val.length,
                          ),
                        ),
                        Container(
                          height: 3.h,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                height: 1.5.h,
                                width: 5.w,
                                decoration: const BoxDecoration(
                                  color: AppColors.primaryAccentColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const Text(
                                ' Available    ',
                                style: TextStyle(fontSize: 8),
                              ),
                              Container(
                                height: 1.5.h,
                                width: 5.w,
                                decoration: new BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.green,
                                ),
                              ),
                              const Text(
                                ' Slot Selected ',
                                style: TextStyle(fontSize: 8),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 4.0,
                        ),
                        (selectedIndex == 0 &&
                                TeleConsultationFunctionsAndVariables
                                    .timingsList[0].categ.morning.isNotEmpty)
                            ? timingSlots(context, "Morning",
                                TeleConsultationFunctionsAndVariables.timingsList[0].categ.morning)
                            : TeleConsultationFunctionsAndVariables
                                    .timingsList[selectedIndex].categ.morning.isEmpty
                                ? SizedBox()
                                : timingSlots(
                                    context,
                                    "Morning",
                                    TeleConsultationFunctionsAndVariables
                                        .timingsList[selectedIndex].categ.morning),
                        (selectedIndex == 0 &&
                                TeleConsultationFunctionsAndVariables
                                    .timingsList[0].categ.afternoon.isNotEmpty)
                            ? timingSlots(
                                context,
                                "Afternoon",
                                TeleConsultationFunctionsAndVariables
                                    .timingsList[0].categ.afternoon)
                            : TeleConsultationFunctionsAndVariables
                                    .timingsList[selectedIndex].categ.afternoon.isEmpty
                                ? SizedBox()
                                : timingSlots(
                                    context,
                                    "Afternoon",
                                    TeleConsultationFunctionsAndVariables
                                        .timingsList[selectedIndex].categ.afternoon),
                        (selectedIndex == 0 &&
                                TeleConsultationFunctionsAndVariables
                                    .timingsList[0].categ.evening.isNotEmpty)
                            ? timingSlots(context, "Evening",
                                TeleConsultationFunctionsAndVariables.timingsList[0].categ.evening)
                            : TeleConsultationFunctionsAndVariables
                                    .timingsList[selectedIndex].categ.evening.isEmpty
                                ? SizedBox()
                                : timingSlots(
                                    context,
                                    "Evening",
                                    TeleConsultationFunctionsAndVariables
                                        .timingsList[selectedIndex].categ.evening),
                      ]);
                    }
                  }),
              SizedBox(
                height: 3.h,
              ),
              ValueListenableBuilder<Map>(
                  valueListenable: TeleConsultationFunctionsAndVariables.selectedDateTile,
                  builder: (BuildContext context, Map v, Widget child) {
                    return Align(
                      alignment: Alignment.center,
                      child: v['time'] == null
                          ? SizedBox()
                          : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                primary: AppColors.primaryAccentColor,
                              ),
                              onPressed: () async {
                                SharedPreferences prefs = await SharedPreferences.getInstance();
                                Object data = prefs.get('data');
                                Map res = jsonDecode(data);
                                if (PercentageCalculations().calculatePercentageFilled() != 100) {
                                  Get.to(ProfileTab(
                                      editing: true,
                                      bacNav: () {
                                        Get.back();
                                      }));
                                } else {
                                  Get.to(ConfirmVisitPage(
                                      fees: consultantFee ?? '0',
                                      liveCall: false,
                                      doctorDetails: widget.doctorDetails,
                                      datadecode: res,
                                      slotSelectedTime: TeleConsultationFunctionsAndVariables
                                          .selectedDateTile.value));
                                }
                              },
                              child: Text("Confirm Appointment",
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                  )),
                            ),
                    );
                  }),
            ],
          ),
          SizedBox(
            height: 13.h,
          )
        ],
      ),
    );
  }

  Widget getDateButton(String tileName, int index) {
    // print(e);
    int _slot = 0;
    String _mor = 'morning', _aft = 'afternoon', _eve = 'evening', _nig = 'night';
    final DateTime _now = DateTime.now();
    TimeOfDay t = TimeOfDay.now();
    DateTime nowTime = DateTime(_now.year, _now.month, _now.day, t.hour, t.minute);
    List e = ['Today', 'Tomorrow', '20th August', '21th August', '22th August'];
    List _list = [];

    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: SizedBox(
        width: 36.w,
        child: Card(
          shape: (index == 0)
              ? RoundedRectangleBorder(
                  side: const BorderSide(color: AppColors.primaryColor, width: 2),
                  borderRadius: BorderRadius.circular(5))
              : null,
          elevation: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                tileName,
                style: const TextStyle(color: AppColors.primaryColor),
              ),
              Text(
                '$_slot slots available',
                style: TextStyle(
                    color: _slot == 0
                        ? Colors.grey
                        : 2 == index
                            ? AppColors.primaryColor
                            : Colors.green),
              ),
            ],
          ),
        ),
      ),
    );
  }

  TimeOfDay timeConvert(String normTime) {
    int hour;
    int minute;
    DateTime convertedTime = DateFormat.jm().parse(normTime);
    hour = convertedTime.hour;
    minute = convertedTime.minute;
    return TimeOfDay(hour: hour, minute: minute);
  }

  Widget timingSlots(BuildContext context, String timing, List timeSlotss) {
    return SizedBox(
      height: 15.h,
      width: 95.5.w,
      child: Card(
        elevation: 4,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 14.sp),
            child: Row(
              children: <Widget>[
                timing == "Morning"
                    ? Image.asset(
                        'newAssets/images/morning.png',
                        width: 8.w,
                        height: 6.h,
                      )
                    : timing == "Afternoon"
                        ? Image.asset(
                            'newAssets/images/Afternoon.png',
                            width: 8.w,
                            height: 6.h,
                          )
                        : Image.asset(
                            'newAssets/images/dinner.png',
                            width: 8.w,
                            height: 6.h,
                          ),
                SizedBox(
                  width: 1.w,
                ),
                Text(timing),
              ],
            ),
          ),
          timeSlotss.toString().isEmpty
              ? const SizedBox()
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      height: 6.h,
                      width: 90.w,
                      child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: timeSlotss
                              .map((e) => Padding(
                                    padding: const EdgeInsets.all(6.0),
                                    child: OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                            foregroundColor: Colors.blue,
                                            backgroundColor: Colors.white,
                                            padding: const EdgeInsets.only(
                                                right: 2, left: 2, top: 1, bottom: 1),
                                            side: const BorderSide(
                                                color: AppColors.primaryAccentColor, width: 2.0)),
                                        child: Container(
                                            color: TeleConsultationFunctionsAndVariables
                                                        .selectedDateTile.value['time'] ==
                                                    e
                                                ? Colors.green
                                                : Colors.white,
                                            height: 8.h,
                                            width: 20.w,
                                            child: Center(
                                                child: Text(
                                              e,
                                              style: TeleConsultationFunctionsAndVariables
                                                          .selectedDateTile.value['time'] ==
                                                      e
                                                  ? const TextStyle(color: Colors.white)
                                                  : const TextStyle(color: Colors.black),
                                            ))),
                                        onPressed: () {
                                          TeleConsultationFunctionsAndVariables
                                              .selectedDateTile.value['time'] = e;
                                          TeleConsultationFunctionsAndVariables.selectedDateTile
                                              .notifyListeners();
                                        }),
                                  ))
                              .toList()),
                    ),
                  ],
                )
        ]),
      ),
    );
  }
}
