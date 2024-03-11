import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import '../../../data/model/TeleconsultationModels/TeleconulstationDashboardModels.dart';
import '../../controllers/teleconsultation_onlineServices/teleconsultation_apiCalls.dart';
import '../../controllers/teleconsultation_onlineServices/teleconsultation_functions.dart';
import '../../pages/dashboard/affiliation_dashboard/affiliationDasboard.dart';
import '../../pages/onlineServices/SearchByDocAndList.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

import '../../../../constants/api.dart';
import '../../../../constants/spKeys.dart';
import '../../../../utils/app_colors.dart';
import '../../../data/model/TeleconsultationModels/appointmentModels.dart';
import '../../../data/model/TeleconsultationModels/doctorModel.dart';
import '../../clippath/subscriptionTagClipPath.dart';
import '../../controllers/dashboardControllers/dashBoardContollers.dart';
import '../../pages/onlineServices/consultationSummary.dart';
import '../../pages/onlineServices/doctorsDescriptionScreen.dart';

class TeleConsultationWidgetsOnlineSevices {
  static Widget specTiles({SpecialityList specialityList}) {
    return InkWell(
      onTap: () => Get.to(SearchByDocAndList(specName: specialityList.specialityName)),
      child: Container(
        height: 30.w,
        width: 45.w,
        decoration:
            BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 3,
              offset: const Offset(0, 0),
              spreadRadius: 3)
        ]),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 15.w,
              width: 15.w,
              child: Image.asset(
                'newAssets/Icons/speciality/${specialityList.specialityName.toLowerCase()}.png',
                errorBuilder: (BuildContext, Object, StackTrace) {
                  return Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey.shade100,
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                specialityList.specialityName,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15.sp),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> fetchData() {
    return Future.delayed(const Duration(seconds: 2), () {
      print("Data has been fetched.");
    });
  }

  static Widget docTiles({DoctorModel doc}) {
    ValueNotifier<String> nextAvaible = ValueNotifier('');
    String consultantFee = doc.consultationFees;
    if (selectedAffiliationfromuniquenameDashboard != "" &&
        selectedAffiliationfromuniquenameDashboard != null) {
      if (doc.affilationExcusiveData != null) {
        for (AffilationArray e in doc.affilationExcusiveData.affilationArray) {
          if (selectedAffiliationfromuniquenameDashboard == e.affilationUniqueName) {
            consultantFee = e.affilationPrice.toString();
          }
        }
      }
    }
    Future.delayed(const Duration(seconds: 2), () async {
      nextAvaible.value = await TeleConsultationFunctionsAndVariables.getConsultantLiveStatus(
          consultantid: doc.ihlConsultantId, vendorId: doc.vendorId);
    });

    Stream _stream =
        FireStoreCollections.consultantOnlineStatus.doc(doc.ihlConsultantId).snapshots();
    doc = doc ?? DoctorModel();
    return InkWell(
      ///Doctor Description Screen
      onTap: () => Get.to(DoctorsDescriptionScreen(
        doctorDetails: doc,
      )),
      child: Container(
        width: 45.w,
        height: 62.w,
        decoration:
            BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(5), boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 3,
              offset: const Offset(0, 0),
              spreadRadius: 3)
        ]),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 0.5.h),
            Row(
              children: [
                SizedBox(
                  height: 4.w,
                  width: 13.w,
                  child: ClipPath(
                      clipper: SubscriptionClipPath(),
                      child: StreamBuilder<DocumentSnapshot>(
                        stream: _stream,
                        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return FutureBuilder(
                                future: TeleConsultationApiCalls.consultantStatus(
                                    consultantID: doc.ihlConsultantId),
                                builder: (BuildContext ctx, AsyncSnapshot data) {
                                  if (data.hasError) {
                                    FireStoreCollections.consultantOnlineStatus
                                        .doc(doc.ihlConsultantId)
                                        .set(<String, String>{
                                      'consultantId': doc.ihlConsultantId,
                                      'status': "Offline"
                                    });
                                  }
                                  if (data.connectionState == ConnectionState.waiting) {
                                    return Container(
                                      color: Colors.grey,
                                      child: const FittedBox(
                                        child: Text(
                                          "Offline",
                                          style:
                                              TextStyle(color: Colors.white, fontFamily: "Poppins"),
                                        ),
                                      ),
                                    );
                                  }
                                  return Container(
                                    color: data.data == "Offline"
                                        ? Colors.grey
                                        : data.data == "Online"
                                            ? Colors.green
                                            : Colors.red,
                                    child: FittedBox(
                                      child: Text(
                                        data.data,
                                        style: const TextStyle(
                                            color: Colors.white, fontFamily: "Poppins"),
                                      ),
                                    ),
                                  );
                                });
                          }
                          if (!snapshot.data.exists ?? true) {
                            FireStoreCollections.consultantOnlineStatus
                                .doc(doc.ihlConsultantId)
                                .set({'consultantId': doc.ihlConsultantId, 'status': "Offline"});
                          }
                          var _data = snapshot.data.data() as Map;
                          String status = "Offline";
                          status = _data['status'];
                          return InkWell(
                              onTap: () {
                                //it's for checking purpose to change the firestore status of the consultant.🍙
                                FireStoreCollections.consultantOnlineStatus
                                    .doc(doc.ihlConsultantId)
                                    .set({
                                  'consultantId': doc.ihlConsultantId,
                                  'status': status == 'Online' ? "Offline" : "Online"
                                });
                              },
                              child: Container(
                                color: status == "Offline"
                                    ? Colors.grey
                                    : status == "Online"
                                        ? Colors.green
                                        : Colors.red,
                                child: FittedBox(
                                  child: Text(
                                    status,
                                    style:
                                        const TextStyle(color: Colors.white, fontFamily: "Poppins"),
                                  ),
                                ),
                              ));
                        },
                      )),
                ),
                const Spacer(),
                SizedBox(
                  width: 13.w,
                  height: 6.w,
                  child: FutureBuilder<Uint8List>(
                    future:
                        TeleConsultationFunctionsAndVariables.vendorImage(vendorName: doc.vendorId),
                    builder: (BuildContext context, AsyncSnapshot<Uint8List> i) {
                      if (i.connectionState == ConnectionState.done) {
                        return Container(
                          width: 13.w,
                          height: 6.w,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            image: DecorationImage(
                              image: MemoryImage(
                                i.data,
                              ),
                            ),
                          ),
                        );
                      } else if (i.connectionState == ConnectionState.waiting) {
                        return Shimmer.fromColors(
                          baseColor: Colors.white,
                          direction: ShimmerDirection.ltr,
                          highlightColor: Colors.grey.withOpacity(0.3),
                          child: Container(
                            width: 13.w,
                            height: 6.w,
                            decoration: const BoxDecoration(color: Colors.white),
                          ),
                        );
                      } else {
                        return Container(
                          width: 13.w,
                          height: 6.w,
                        );
                      }
                    },
                  ),
                ),
                SizedBox(width: 1.w),
              ],
            ),
            SizedBox(height: 0.5.h),
            SizedBox(
              width: 18.w,
              height: 18.w,
              child: FutureBuilder<String>(
                future: TabBarController().getConsultantImageUrl(doctor: doc.toJson() ?? {}),
                builder: (BuildContext context, AsyncSnapshot<String> i) {
                  if (i.connectionState == ConnectionState.done) {
                    doc.docImage = i.data.toString();

                    Uint8List _bytes = base64Decode(i.data.toString());
                    return Container(
                      width: 18.w,
                      height: 18.w,
                      decoration: BoxDecoration(
                        color: const Color(0xff7c94b6),
                        borderRadius: const BorderRadius.all(Radius.circular(4.0)),
                        image: DecorationImage(image: MemoryImage(_bytes), fit: BoxFit.cover),
                      ),
                    );
                  } else if (i.connectionState == ConnectionState.waiting) {
                    return Shimmer.fromColors(
                      baseColor: Colors.white,
                      highlightColor: Colors.grey.withOpacity(0.3),
                      direction: ShimmerDirection.ltr,
                      child: Container(
                        width: 18.w,
                        height: 18.w,
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
                    return Container(width: 18.w, height: 18.w);
                  }
                },
              ),
            ),
            SizedBox(height: 0.5.h),
            Expanded(
              // width: 45.w,
              child: Padding(
                padding: EdgeInsets.only(left: 12.sp, right: 4.sp),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doc.name.toString(),
                      style: TextStyle(
                          color: Colors.black,
                          fontFamily: "Poppins",
                          fontSize: 14.5.sp,
                          letterSpacing: 0.3,
                          fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        Text(
                          "Consultation fee : ",
                          style: TextStyle(
                              color: Colors.black.withOpacity(0.6),
                              fontFamily: "Poppins",
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          " ₹ ",
                          style: TextStyle(
                              color: AppColors.primaryColor,
                              fontFamily: "Poppins",
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          consultantFee ?? "0",
                          style: TextStyle(
                              color: Colors.black.withOpacity(0.6),
                              fontFamily: "Poppins",
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Text(
                      "Experience ${doc.experience.toString()}",
                      style: TextStyle(
                          color: Colors.black.withOpacity(0.6),
                          fontFamily: "Poppins",
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      width: 45.w,
                      child: Wrap(
                        children: [
                          Text(
                            "Languages - ",
                            style: TextStyle(
                                color: Colors.black.withOpacity(0.6),
                                fontFamily: "Poppins",
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            doc.languagesSpoken.first,
                            style: TextStyle(
                                color: Colors.black.withOpacity(0.6),
                                fontFamily: "Poppins",
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold),
                          ),
                          if (doc.languagesSpoken.length > 2)
                            Text(
                              ", " + doc.languagesSpoken[1],
                              style: TextStyle(
                                  color: Colors.black.withOpacity(0.6),
                                  fontFamily: "Poppins",
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.bold),
                            ),
                          if (doc.languagesSpoken.length > 3)
                            Text(
                              " +${(doc.languagesSpoken.length - 2).toString()} more",
                              style: TextStyle(
                                  color: AppColors.primaryColor,
                                  fontFamily: "Poppins",
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.bold),
                            ),
                        ],
                      ),
                    ),
                    Wrap(
                      children: [
                        Icon(Icons.star, color: AppColors.primaryColor, size: 14.sp),
                        SizedBox(width: 0.5.w),
                        Text(
                          "${doc.ratings.toString()} Rating",
                          style: TextStyle(
                              color: Colors.black.withOpacity(0.6),
                              fontFamily: "Poppins",
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          "Available at  ",
                          style: TextStyle(
                              color: Colors.black.withOpacity(0.6),
                              fontFamily: "Poppins",
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold),
                        ),
                        // Text(
                        //   "$_nextAvaible",
                        //   style: TextStyle(
                        //       color: AppColors.primaryColor,
                        //       fontFamily: "Poppins",
                        //       fontSize: 13.sp,
                        //       fontWeight: FontWeight.bold),
                        // ),
                        ValueListenableBuilder<String>(
                            valueListenable: nextAvaible,
                            builder: (c, val, _) {
                              return val.isEmpty
                                  ? Shimmer.fromColors(
                                      baseColor: Colors.grey[300],
                                      highlightColor: Colors.grey[100],
                                      child: Container(
                                        width: 15.w,
                                        height: 1.h,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      val,
                                      style: TextStyle(
                                          color: AppColors.primaryColor,
                                          fontFamily: "Poppins",
                                          fontSize: 12.5.sp,
                                          fontWeight: FontWeight.bold),
                                    );
                            })
                      ],
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  static Widget tabbar({String titile, String selectedTile}) {
    bool selected = titile == selectedTile;
    return Padding(
      padding: EdgeInsets.only(left: 2.w),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Material(
            color: Colors.transparent,
            borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(0),
                bottomRight: Radius.circular(25),
                topLeft: Radius.circular(25),
                topRight: Radius.circular(0)),
            elevation: selected ? 0 : 3,
            child: ClipPath(
                clipper: const ShapeBorderClipper(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(0),
                            bottomRight: Radius.circular(25),
                            topLeft: Radius.circular(25),
                            topRight: Radius.circular(0)))),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 12.w,
                  // width: 30.w,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: const Color(0XFFDCDBDB),
                      border: selected
                          ? Border(bottom: BorderSide(color: AppColors.primaryColor, width: 1.w))
                          : null),
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                  child: Text(
                    titile,
                    textAlign: TextAlign.center,
                  ),
                )),
          ),
          SizedBox(height: 2.w)
        ],
      ),
    );
  }

  static Widget appointmenttabbar({String title, String selectedTile}) {
    bool selected = title == selectedTile;
    if (title == "Canceled") {
      title = "Cancelled";
    }
    return Padding(
      padding: EdgeInsets.all(1.5.w),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Material(
            color: Colors.transparent,
            borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(0),
                bottomRight: Radius.circular(25),
                topLeft: Radius.circular(25),
                topRight: Radius.circular(0)),
            elevation: selected ? 0 : 3,
            child: ClipPath(
                clipper: const ShapeBorderClipper(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(0),
                            bottomRight: Radius.circular(25),
                            topLeft: Radius.circular(25),
                            topRight: Radius.circular(0)))),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 6.h,
                  width: 30.w,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: const Color(0XFFDCDBDB),
                      border: selected
                          ? Border(bottom: BorderSide(color: AppColors.primaryColor, width: 1.w))
                          : null),
                  padding: EdgeInsets.all(3.w),
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                  ),
                )),
          ),
          SizedBox(height: 2.w)
        ],
      ),
    );
  }

  static Widget showReviewRatingDialog(Map data) {
    var _rating = 0.0.obs;
    var _ratingController = TextEditingController();
    RxBool submitting = false.obs;
    var consultantName = data['consultant_name'];
    return SingleChildScrollView(
        child: Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      SizedBox(
        height: 7.h,
      ),
      Text(
        "Rate Your Experience",
        style: TextStyle(
          color: const Color(0xff6D6E71),
          fontSize: 18.sp,
        ),
      ),
      SizedBox(
        height: 1.2.h,
      ),
      Text(
        "Your Ratings",
        style: TextStyle(
          color: AppColors.primaryColor,
          fontSize: 17.sp,
        ),
      ),
      SizedBox(
        height: 1.2.h,
      ),
      Obx(() => SmoothStarRating(
            allowHalfRating: false,
            starCount: 5,
            rating: _rating.value,
            size: 40.0,
            isReadOnly: false,
            color: Colors.amberAccent,
            borderColor: Colors.grey,
            spacing: 0.0,
            onRated: (value) {
              _rating.value = value;
            },
          )),
      SizedBox(
        height: 1.2.h,
      ),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 5.w),
        child: TextFormField(
          autocorrect: true,
          controller: _ratingController,
          keyboardType: TextInputType.visiblePassword,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 18),
            labelText: "Your feedback for " + consultantName.toString(),
            fillColor: Colors.white24,
            border: new OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.sp),
                borderSide: new BorderSide(color: AppColors.primaryAccentColor)),
          ),
          style: TextStyle(fontSize: 16.sp),
          maxLines: 4,
          textInputAction: TextInputAction.done,
        ),
      ),
      SizedBox(
        height: 2.2.h,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Obx(() {
            return ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: Size(22.w, 4.5.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6.sp),
                ),
                primary: AppColors.primaryColor,
                textStyle: const TextStyle(color: Colors.white),
              ),
              child: const Text(
                'Skip',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: submitting.value == true
                  ? null
                  : () {
                      Get.back();
                    },
            );
          }),
          Obx(() {
            return ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: Size(22.w, 4.5.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6.sp),
                ),
                primary: AppColors.primaryColor,
                textStyle: const TextStyle(color: Colors.white),
              ),
              child: submitting.value == true
                  ? SizedBox(
                      height: 20.0,
                      width: 20.0,
                      child: new CircularProgressIndicator(
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Submit',
                      style: TextStyle(color: Colors.white),
                    ),
              onPressed: submitting.value == true
                  ? null
                  : () async {
                      submitting.value = true;
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      var _data = prefs.get(SPKeys.userData);

                      var userData = json.decode(_data);
                      var userid = userData['User']['id'];
                      data['user_ihl_id'] = userid;
                      data['ratings'] = _rating.value.toInt();
                      data['review_text'] = _ratingController.text;
                      print(data);
                      try {
                        await TeleConsultationApiCalls.insertRatingApi(data);
                        submitting.value = false;
                      } catch (e) {
                        submitting.value = false;

                        throw Exception('Failed');
                      }
                      Fluttertoast.showToast(
                          msg: "Submitting review!",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.grey,
                          textColor: Colors.white,
                          fontSize: 16.0);
                    },
            );
          }),
        ],
      ),
    ]));
  }

  static Widget completedAndCancelled({CompletedAppointment appointment, var refundOntap}) {
    // DateFormat inputFormat = DateFormat("EEEE, MMMM d, yyyy h:mm:ss a", "en_US");
    DateFormat inputFormat = DateFormat("yyyy-MM-dd hh:mm aa");
    DateTime originalDateTime = inputFormat.parse(appointment.appointmentStartTime);
    String formattedDateTime = DateFormat("yyyy-MM-dd hh:mm a").format(originalDateTime);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () => Get.to(ConsultationSummaryScreen(
          fromCall: false,
          appointmentId: appointment.appointmentId,
          // completeAppointment: appointment,
        )),
        child: Container(
          width: 90.h,
          padding: const EdgeInsets.all(8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            boxShadow: <BoxShadow>[
              BoxShadow(
                  offset: const Offset(0, 0),
                  blurRadius: 3,
                  spreadRadius: 3,
                  color: Colors.grey.shade200)
            ],
            color: Colors.white,
          ),
          child: Row(
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              SizedBox(
                height: 3.h,
                width: 3.h,
                child: Image.asset("newAssets/Icons/call_icon.png"),
              ),
              SizedBox(width: 3.w),
              FutureBuilder<String>(
                future: TabBarController()
                    .getConsultantImageUrl(doctor: appointment.toJson() ?? <dynamic, dynamic>{}),
                builder: (BuildContext context, AsyncSnapshot<String> i) {
                  if (i.connectionState == ConnectionState.done) {
                    Uint8List bytes = base64Decode(i.data.toString());
                    return Container(
                      width: 7.h,
                      height: 7.h,
                      decoration: BoxDecoration(
                        color: const Color(0xff7c94b6),
                        shape: BoxShape.circle,
                        image: DecorationImage(image: MemoryImage(bytes), fit: BoxFit.cover),
                      ),
                    );
                  } else if (i.connectionState == ConnectionState.waiting) {
                    return Shimmer.fromColors(
                      baseColor: Colors.white,
                      highlightColor: Colors.grey.withOpacity(0.3),
                      direction: ShimmerDirection.ltr,
                      child: Container(
                        width: 7.h,
                        height: 7.h,
                        decoration: const BoxDecoration(
                          color: Color(0xff7c94b6),
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  } else {
                    return SizedBox(width: 7.h, height: 7.h);
                  }
                },
              ),
              SizedBox(width: 3.w),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        width: appointment.isExpired ? 44.w : 56.2.w,
                        child: Text(appointment.consultantName,
                            textAlign: TextAlign.start,
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.5.sp),
                            maxLines: 1),
                      ),
                      Visibility(
                          visible: appointment.isExpired,
                          replacement: SizedBox(width: 2.w),
                          child: Image.asset(
                            'newAssets/Icons/expired.png',
                            width: 16.w,
                            height: 3.h,
                            fit: BoxFit.cover,
                          )),
                      InkWell(
                        onTap: () {
                          Get.to(ConsultationSummaryScreen(
                            // completeAppointment: appointment,
                            fromCall: false,
                            appointmentId: appointment.appointmentId,
                          ));
                        },
                        child: Icon(
                          Icons.info,
                          size: 16.px,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.w),
                  Text(
                    formattedDateTime,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.w500, fontSize: 14.sp),
                    maxLines: 2,
                  ),
                  SizedBox(height: 1.w),
                  Text(
                    "Appointment : ${appointment.appointmentStatus}",
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.w500, fontSize: 14.sp),
                    maxLines: 2,
                  ),
                  SizedBox(height: 1.w),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      SizedBox(
                        width: 51.w,
                        child: Text(
                          "Call status : ${appointment.callStatus}",
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.w500, fontSize: 14.sp),
                          maxLines: 1,
                        ),
                      ),
                      Visibility(
                          visible: appointment.isExpired,
                          child: InkWell(
                              onTap: refundOntap,
                              child: Text(
                                'Refund',
                                style: TextStyle(
                                    color: AppColors.primaryColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15.sp),
                              )))
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
