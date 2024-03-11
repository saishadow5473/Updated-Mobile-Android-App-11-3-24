import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/utils/appColors.dart';
import '../../controllers/dashboardControllers/dashBoardContollers.dart';
import '../../pages/spalshScreen/splashScreen.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

// import 'package:sizer/sizer.dart';

import '../../../app/utils/appText.dart';
import '../../../app/utils/constLists.dart';
import '../../../app/utils/imageAssets.dart';
import '../../../app/utils/localStorageKeys.dart';
import '../../../app/utils/textStyle.dart';
import '../../clippath/subscriptionTagClipPath.dart';
import '../../pages/manageHealthscreens/myVitalsScreens/myVitalsGraphScreen.dart';

class VitalCardsIndiduval extends StatelessWidget {
  const VitalCardsIndiduval(
      {Key key, @required this.vitalType, @required this.icon, @required this.show})
      : super(key: key);
  final vitalType;
  final icon;
  final show;

  DateTime getDateTimeStamp(String d) {
    try {
      return DateTime.fromMillisecondsSinceEpoch(int.tryParse(d
          .substring(0, d.indexOf('+'))
          .replaceAll('Date', '')
          .replaceAll('/', '')
          .replaceAll('(', '')
          .replaceAll(')', '')));
    } catch (e) {
      return DateTime.now();
    }
  }

  @override
  Widget build(BuildContext context) {
    final TabBarController tabController = Get.find();
    var vital = localSotrage.read(LSKeys.vitalsData);
    // var vital = jsonDecode(SpUtil.getString(LSKeys.vitalsData));
    var vitalStatus = localSotrage.read(LSKeys.vitalStatus);
    // var vitalStatus = jsonDecode(SpUtil.getString(LSKeys.vitalStatus));
    var checkinData = localSotrage.read(LSKeys.allScors);
    var createdDate = localSotrage.read("createdDate");
    // var checkinData = jsonDecode(SpUtil.getString(LSKeys.allScors));
    var vitalValue = vital[vitalType];
    print(vital["Weight"] != null);
    // print(checkinData["weightKG"]);
    // vital["Weight"] != null && checkinData ==null
    //     ?
    return (vitalValue != null && vitalValue != "") || show
        ? Visibility(
            visible: (vitalValue != null && vitalValue != "") || show,
            child: GestureDetector(
              onTap: vitalValue != "NaN" &&
                      vitalValue != null &&
                      vitalValue != "0" &&
                      vitalValue != "0.0" &&
                      vitalValue != 0
                  ? () {
                      String vitalName;
                      var vlaueofVitla;
                      switch (vitalType) {
                        case "BP":
                          {
                            vitalName = "bp";
                            vlaueofVitla = vitalValue;
                          }
                          break;
                        case "BMI":
                          {
                            vitalName = "bmi";
                            vlaueofVitla = vitalValue.runtimeType == String
                                ? vitalValue
                                : vitalValue.toStringAsFixed(2);
                          }
                          break;
                        case "Waist Hip":
                          {
                            vitalName = "waist_hip_ratio";
                            vlaueofVitla = vitalValue.runtimeType == String
                                ? vitalValue
                                : vitalValue.toStringAsFixed(2);
                          }
                          break;
                        case "Mineral":
                          {
                            vitalName = "mineral";
                            vlaueofVitla = vitalValue.runtimeType == String
                                ? vitalValue
                                : vitalValue.toStringAsFixed(2);
                          }
                          break;
                        case "Pulse":
                          {
                            vitalName = "pulseBpm";
                            vlaueofVitla = vitalValue.runtimeType == String
                                ? vitalValue
                                : vitalValue.toStringAsFixed(0);
                          }
                          break;
                        case "TEMP":
                          {
                            vitalName = "temperature";
                            vlaueofVitla = vitalValue.runtimeType == String
                                ? vitalValue
                                : vitalValue.toStringAsFixed(2);
                          }
                          break;
                        case "ECG":
                          {
                            vitalName = "ECGBpm";
                            vlaueofVitla = vitalValue.runtimeType == String
                                ? vitalValue
                                : vitalValue.toStringAsFixed(0);
                          }
                          break;
                        case "SPO2":
                          {
                            vitalName = "spo2";
                            vlaueofVitla = vitalValue.runtimeType == String
                                ? vitalValue
                                : vitalValue.toStringAsFixed(0);
                          }
                          break;
                        case "Weight":
                          {
                            vitalName = "weightKG";
                            vlaueofVitla = vitalValue.runtimeType == String
                                ? vitalValue
                                : vitalValue.toStringAsFixed(2);
                          }
                          break;
                        case "ECW":
                          {
                            vitalName = "extra_cellular_water";
                            vlaueofVitla = vitalValue.runtimeType == String
                                ? vitalValue
                                : vitalValue.toStringAsFixed(2);
                          }
                          break;
                        case "ICW":
                          {
                            vitalName = "intra_cellular_water";
                            vlaueofVitla = vitalValue.runtimeType == String
                                ? vitalValue
                                : vitalValue.toStringAsFixed(2);
                          }
                          break;
                        case "BFM":
                          {
                            vitalName = "body_fat_mass";
                            vlaueofVitla = vitalValue.runtimeType == String
                                ? vitalValue
                                : vitalValue.toStringAsFixed(2);
                          }
                          break;
                        case "Protein":
                          {
                            vitalName = "protien";
                            vlaueofVitla = vitalValue.runtimeType == String
                                ? vitalValue
                                : vitalValue.toStringAsFixed(2);
                          }
                          break;
                        case "PBF":
                          {
                            vitalName = "percent_body_fat";
                            vlaueofVitla = vitalValue.runtimeType == String
                                ? vitalValue
                                : vitalValue.toStringAsFixed(2);
                          }
                          break;
                        case "WtHR":
                          {
                            vitalName = "waist_height_ratio";
                            vlaueofVitla = vitalValue.runtimeType == String
                                ? vitalValue
                                : vitalValue.toStringAsFixed(2);
                          }
                          break;
                        case "VF":
                          {
                            vitalName = "visceral_fat";
                            vlaueofVitla = vitalValue.runtimeType == String
                                ? vitalValue
                                : vitalValue.toStringAsFixed(0);
                          }
                          break;
                        case "BMR":
                          {
                            vitalName = "basal_metabolic_rate";
                            vlaueofVitla = vitalValue.runtimeType == String
                                ? vitalValue
                                : vitalValue.toStringAsFixed(0);
                          }
                          break;
                        case "BMC":
                          {
                            vitalName = "bone_mineral_content";
                            vlaueofVitla = vitalValue.runtimeType == String
                                ? vitalValue
                                : vitalValue.toStringAsFixed(2);
                          }
                          break;
                        case "BCM":
                          {
                            vitalName = "body_cell_mass";
                            vlaueofVitla = vitalValue.runtimeType == String
                                ? vitalValue
                                : vitalValue.toStringAsFixed(2);
                          }
                          break;
                        case "SMM":
                          {
                            vitalName = "skeletal_muscle_mass";
                            vlaueofVitla = vitalValue.runtimeType == String
                                ? vitalValue
                                : vitalValue.toStringAsFixed(2);
                          }
                          break;
                      }

                      if (checkinData == null || checkinData == []) {
                        checkinData = {
                          "bmi": [
                            {
                              'value': vitalValue.runtimeType == String
                                  ? vitalValue
                                  : vitalValue.toStringAsFixed(2),
                              'status': vitalStatus["${vitalType.replaceAll(' ', '')}_status"],
                              'date': getDateTimeStamp(createdDate),
                              'moreData': {
                                'Address': "na",
                                'City': "na",
                              }
                            }
                          ],
                          "weightKG": [
                            {
                              'value': vitalValue.runtimeType == String
                                  ? vitalValue
                                  : vitalValue.toStringAsFixed(2),
                              'status': vitalStatus["${vitalType.replaceAll(' ', '')}_status"],
                              // 'date': userVitals[i]['dateTimeFormatted'] != null
                              //     ? DateTime.tryParse(userVitals[i]['dateTimeFormatted'].toString())
                              //     : getDateTimeStamp(user['accountCreated']),
                              'date': getDateTimeStamp(createdDate),
                              'moreData': {
                                'Address': "na",
                                'City': "na",
                              }
                            }
                          ]
                        };
                      }

                      Map arg = {
                        'vitalType': vitalName,
                        'status': vitalStatus["${vitalType.replaceAll(' ', '')}_status"],
                        'value': vlaueofVitla,
                        'data': checkinData[vitalName]
                      };
                      tabController.updateSelectedIconValue(value: AppTexts.manageHealth);
                      // Navigator.pushNamed(context, "vital_screen", arguments: arg);
                      Get.to(MyVitalGraphScreen(
                        data: arg,
                        navPath: show ? null : "home",
                      ));
                    }
                  : () {},
              child: show
                  ? vitalValue != "NaN" &&
                          vitalValue != null &&
                          vitalValue != "0" &&
                          vitalValue != "0.0" &&
                          vitalValue != 0
                      ? Card(
                          color: AppColors.plainColor,
                          elevation: 3,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(top: .5.h),
                                child: SizedBox(
                                  child: vitalType != "BMR" &&
                                          vitalType != "ECG" &&
                                          vitalType != "Weight"
                                      ? SizedBox(
                                          height: 3.w,
                                          width: 7.w,
                                          child: ClipPath(
                                            clipper: SubscriptionClipPath(),
                                            child: Container(
                                                color: vitalType == "SPO2" &&
                                                        vitalStatus[
                                                                "${vitalType.replaceAll(' ', '')}_status"] ==
                                                            "Low"
                                                    ? colorForStatus("High")
                                                    : colorForStatus(vitalStatus[
                                                        "${vitalType.replaceAll(' ', '')}_status"])),
                                          ),
                                        )
                                      : SizedBox(
                                          width: 8.w,
                                        ),
                                ),
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Image(
                                    width: 25.sp,
                                    height: 23.sp,
                                    image: icon,
                                  ),
                                  SizedBox(
                                    width: 100.w > 300 ? 24.w : 27.w,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "$vitalType ",
                                        style: AppTextStyles.vitalsText2,
                                      ),
                                      vitalType == "VF" ||
                                              vitalType == "ECG" ||
                                              vitalType == "BMR" ||
                                              vitalType == "SPO2"
                                          ? Text(
                                              vitalValue.runtimeType == String
                                                  ? "$vitalValue "
                                                  : "${vitalValue.toStringAsFixed(0)} ",
                                            )
                                          : Text(
                                              vitalValue.runtimeType == String
                                                  ? "$vitalValue "
                                                  : "${vitalValue.toStringAsFixed(2)} ",
                                            ),
                                      Text(
                                        ProgramLists.vitalsUnit[vitalType],
                                        style: AppTextStyles.vitalsUnit,
                                      )
                                    ],
                                  ),
                                  Visibility(
                                    visible: vitalType != "BMR" &&
                                        vitalType != "ECG" &&
                                        vitalType != "Weight",
                                    child: vitalStatus["${vitalType.replaceAll(' ', '')}_status"] ==
                                            "Clinical Screening Recommended"
                                        ? Text("Clinical Screening \n  Recommended",
                                            style: TextStyle(
                                              fontFamily: 'Poppins',
                                              fontSize: 14.sp,
                                              color:
                                                  "${vitalStatus["${vitalType.replaceAll(' ', '')}_status"]}"
                                                          .contains('Doctor Attention Needed')
                                                      ? const Color.fromARGB(255, 216, 163, 4)
                                                      : colorForStatus(vitalStatus[
                                                          "${vitalType.replaceAll(' ', '')}_status"]),
                                              fontWeight: FontWeight.w400,
                                            ))
                                        : vitalStatus["${vitalType.replaceAll(' ', '')}_status"] ==
                                                "Check with healthcare provider"
                                            ? Text("Check with \nhealthcare provider",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontFamily: 'Poppins',
                                                  fontSize: 14.sp,
                                                  color: "${vitalStatus["${vitalType.replaceAll(' ', '')}_status"]}"
                                                          .contains('Doctor Attention Needed')
                                                      ? const Color.fromARGB(255, 216, 163, 4)
                                                      : colorForStatus(vitalStatus[
                                                          "${vitalType.replaceAll(' ', '')}_status"]),
                                                  fontWeight: FontWeight.w400,
                                                ))
                                            : Text(
                                                "${vitalStatus["${vitalType.replaceAll(' ', '')}_status"].contains('Doctor Attention Needed') ? 'Low' : vitalStatus["${vitalType.replaceAll(' ', '')}_status"]} "
                                                        .capitalize ??
                                                    " ",
                                                maxLines: 3,
                                                style: TextStyle(
                                                  fontFamily: 'Poppins',
                                                  fontSize: 15.sp,
                                                  color: colorForStatus(vitalStatus[
                                                      "${vitalType.replaceAll(' ', '')}_status"]),
                                                  fontWeight: FontWeight.w400,
                                                )

                                                //  vitalStatus[
                                                //                 "${vitalType.replaceAll(' ', '')}_status"] ==
                                                //             "Normal" ||
                                                //         vitalStatus[
                                                //                 "${vitalType.replaceAll(' ', '')}_status"] ==
                                                //             "normal"
                                                //     ? AppTextStyles.normalStatus
                                                //     : vitalStatus["${vitalType.replaceAll(' ', '')}_status"] ==
                                                //                 "High" ||
                                                //             vitalStatus[
                                                //                     "${vitalType.replaceAll(' ', '')}_status"] ==
                                                //                 "high"
                                                //         ? AppTextStyles.highStatus
                                                //         : AppTextStyles.lowStatus,
                                                ),
                                  )
                                ],
                              ),
                              Padding(
                                padding: EdgeInsets.only(bottom: 1.h, right: 1.w),
                                child: Container(
                                  child: Image(
                                    width: 20.sp,
                                    height: 28.sp,
                                    image: ImageAssets.chartUP,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : Card(
                          color: AppColors.plainColor,
                          elevation: 3,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(top: .5.h),
                                child: SizedBox(
                                  child: vitalType != "BMR" &&
                                          vitalType != "ECG" &&
                                          vitalType != "Weight"
                                      ? Image(
                                          width: 8.w,
                                          image: ImageAssets.disabledStatusTag,
                                        )
                                      : SizedBox(
                                          width: 8.w,
                                        ),
                                ),
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Image(
                                        width: 25.sp,
                                        height: 23.sp,
                                        image: icon,
                                        opacity: const AlwaysStoppedAnimation(.5),
                                        color: Colors.white54,
                                        colorBlendMode: BlendMode.softLight),
                                  ),
                                  SizedBox(
                                    width: 100.w > 300 ? 24.w : 27.w,
                                  ),
                                  Text(
                                    "$vitalType",
                                    style: AppTextStyles.disabledVitalsText,
                                  ),
                                  SizedBox(
                                    width: 100.w > 300 ? 24.w : 27.w,
                                  ),
                                ],
                              ),
                              Padding(
                                padding: EdgeInsets.only(bottom: 1.h, right: 1.w),
                                child: Container(
                                  child: Image(
                                      width: 20.sp,
                                      height: 28.sp,
                                      image: ImageAssets.chartUP,
                                      opacity: const AlwaysStoppedAnimation(.5),
                                      color: Colors.white54,
                                      colorBlendMode: BlendMode.softLight),
                                ),
                              ),
                            ],
                          ),
                        )
                  : Visibility(
                      visible: vitalValue != "NaN" &&
                          vitalValue != null &&
                          vitalValue != "0" &&
                          vitalValue != "0.0" &&
                          vitalValue != 0,
                      child: Card(
                        color: AppColors.plainColor,
                        elevation: 3,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(top: .5.h),
                              child: SizedBox(
                                child: vitalType != "BMR" &&
                                        vitalType != "ECG" &&
                                        vitalType != "Weight"
                                    ? SizedBox(
                                        height: 3.w,
                                        width: 8.w,
                                        child: ClipPath(
                                          clipper: SubscriptionClipPath(),
                                          child: Container(
                                              color: vitalType == "SPO2" &&
                                                      vitalStatus[
                                                              "${vitalType.replaceAll(' ', '')}_status"] ==
                                                          "Low"
                                                  ? colorForStatus("High")
                                                  : colorForStatus(vitalStatus[
                                                      "${vitalType.replaceAll(' ', '')}_status"])),
                                        ),
                                      )
                                    // Image(
                                    //     width: 8.w,
                                    //     image: vitalStatus[
                                    //                     "${vitalType.replaceAll(' ', '')}_status"] ==
                                    //                 "Normal" ||
                                    //             vitalStatus[
                                    //                     "${vitalType.replaceAll(' ', '')}_status"] ==
                                    //                 "normal"
                                    //         ? ImageAssets.normalStatusTag
                                    //         : vitalStatus["${vitalType.replaceAll(' ', '')}_status"] ==
                                    //                     "Normal" ||
                                    //                 vitalStatus[
                                    //                         "${vitalType.replaceAll(' ', '')}_status"] ==
                                    //                     "normal"
                                    //             ? ImageAssets.normalStatusTag
                                    //             : vitalStatus["${vitalType.replaceAll(' ', '')}_status"] ==
                                    //                         "High" ||
                                    //                     vitalStatus[
                                    //                             "${vitalType.replaceAll(' ', '')}_status"] ==
                                    //                         "high"
                                    //                 ? ImageAssets.highStatusTag
                                    //                 : ImageAssets.lowStatusTag,
                                    //   )
                                    : SizedBox(
                                        width: 8.w,
                                      ),
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Image(
                                  width: 30.sp,
                                  height: 25.sp,
                                  image: icon,
                                ),
                                SizedBox(
                                  width: 100.w > 300 ? 24.w : 27.w,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "$vitalType ",
                                      style: AppTextStyles.vitalsText,
                                    ),
                                    vitalType == "VF" ||
                                            vitalType == "ECG" ||
                                            vitalType == "BMR" ||
                                            vitalType == "SPO2"
                                        ? Text(
                                            vitalValue.runtimeType == String
                                                ? "$vitalValue "
                                                : "${vitalValue.toStringAsFixed(0)} ",
                                          )
                                        : Text(
                                            vitalValue.runtimeType == String
                                                ? "$vitalValue "
                                                : "${vitalValue.toStringAsFixed(2)} ",
                                          ),
                                    Text(
                                      ProgramLists.vitalsUnit[vitalType],
                                      style: AppTextStyles.vitalsUnit,
                                    )
                                  ],
                                ),
                                Visibility(
                                  visible: vitalType != "BMR" &&
                                      vitalType != "ECG" &&
                                      vitalType != "Weight",
                                  child: vitalStatus["${vitalType.replaceAll(' ', '')}_status"] ==
                                          "Clinical Screening Recommended"
                                      ? Text("Clinical Screening \n  Recommended",
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 14.sp,
                                            color:
                                                "${vitalStatus["${vitalType.replaceAll(' ', '')}_status"]}"
                                                        .contains('Doctor Attention Needed')
                                                    ? const Color.fromARGB(255, 216, 163, 4)
                                                    : colorForStatus(vitalStatus[
                                                        "${vitalType.replaceAll(' ', '')}_status"]),
                                            fontWeight: FontWeight.w400,
                                          ))
                                      : vitalStatus["${vitalType.replaceAll(' ', '')}_status"] ==
                                              "Check with healthcare provider"
                                          ? Text("Check with \nhealthcare provider",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontFamily: 'Poppins',
                                                fontSize: 14.sp,
                                                color: "${vitalStatus["${vitalType.replaceAll(' ', '')}_status"]}"
                                                        .contains('Doctor Attention Needed')
                                                    ? const Color.fromARGB(255, 216, 163, 4)
                                                    : colorForStatus(vitalStatus[
                                                        "${vitalType.replaceAll(' ', '')}_status"]),
                                                fontWeight: FontWeight.w400,
                                              ))
                                          : vitalType == "SPO2" &&
                                                  vitalStatus[
                                                          "${vitalType.replaceAll(' ', '')}_status"] ==
                                                      "Low"
                                              ? Text(
                                                  "${vitalStatus["${vitalType.replaceAll(' ', '')}_status"]}"
                                                          .contains('Doctor Attention Needed')
                                                      ? 'Clinical Screening Recommended'
                                                      : "${vitalStatus["${vitalType.replaceAll(' ', '')}_status"]}"
                                                              .capitalizeFirst
                                                              .capitalize ??
                                                          " ",
                                                  style: TextStyle(
                                                    fontFamily: 'Poppins',
                                                    fontSize: 16.sp,
                                                    color:
                                                        "${vitalStatus["${vitalType.replaceAll(' ', '')}_status"]}"
                                                                .contains('Doctor Attention Needed')
                                                            ? const Color.fromARGB(255, 216, 163, 4)
                                                            : colorForStatus("High"),
                                                    fontWeight: FontWeight.w400,
                                                  ))
                                              : Text(
                                                  "${vitalStatus["${vitalType.replaceAll(' ', '')}_status"]}"
                                                          .contains('Doctor Attention Needed')
                                                      ? 'Clinical Screening Recommended'
                                                      : "${vitalStatus["${vitalType.replaceAll(' ', '')}_status"]}"
                                                              .capitalizeFirst
                                                              .capitalize ??
                                                          " ",
                                                  style: TextStyle(
                                                    fontFamily: 'Poppins',
                                                    fontSize: 16.sp,
                                                    color: "${vitalStatus["${vitalType.replaceAll(' ', '')}_status"]}"
                                                            .contains('Doctor Attention Needed')
                                                        ? const Color.fromARGB(255, 216, 163, 4)
                                                        : colorForStatus(vitalStatus[
                                                            "${vitalType.replaceAll(' ', '')}_status"]),
                                                    fontWeight: FontWeight.w400,
                                                  )),
                                )
                              ],
                            ),
                            Padding(
                              padding: EdgeInsets.only(bottom: 1.h, right: 1.w),
                              child: Container(
                                child: Image(
                                  width: 20.sp,
                                  height: 28.sp,
                                  image: ImageAssets.chartUP,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          )
        : Container();
  }

  colorForStatus(riskLevel) {
    riskLevel = riskLevel.toString().capitalizeFirst;
    if (riskLevel == 'Underweight') {
      return const Color(0xfffdc135);
    } else if (riskLevel == 'Normal') {
      return const Color(0xff7ac744);
    } else if (riskLevel == 'Overweight') {
      return const Color(0xffFE712C);
    } else if (riskLevel == 'Obese' || riskLevel == "High") {
      return const Color(0xffBA1616);
    } else if (riskLevel == 'Border Line') {
      return const Color(0xfffd712c);
    } else if (riskLevel == "Low") {
      return const Color(0xfffdc135);
    } else if (riskLevel == 'Acceptable') {
      return const Color(0xffFE712C);
    } else {
      return const Color(0xffBA1616);
    }
  }
}
