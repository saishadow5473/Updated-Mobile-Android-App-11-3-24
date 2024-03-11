import 'package:flutter/material.dart';

import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../functionalities/draft_data.dart';
import '../../../../app/utils/appColors.dart';
import 'package:intl/intl.dart';

import 'package:responsive_sizer/responsive_sizer.dart';

import '../../../../../utils/screenutil.dart';
import 'MobileNumber.dart';

class DobScreen extends StatelessWidget {
  const DobScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ValueNotifier<bool> isDateSelected = ValueNotifier<bool>(false);
    ValueNotifier<String> SelectedDate = ValueNotifier<String>('');
    DateFormat newFormat = DateFormat("MM/dd/yyyy");
    ScUtil.init(context, width: 360, height: 640, allowFontScaling: true);
    DraftData saveData = DraftData();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryAccentColor,
        title: const Text('Choose your Date of Birth'),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.keyboard_arrow_left,
            size: 28.sp,
          ),
          onPressed: () => Get.back(),
        ),
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 9.h,
          ),
          Container(
            height: 24.h,
            width: 100.w,
            decoration: const BoxDecoration(
                image: DecorationImage(image: AssetImage('newAssets/images/dob.png'))),
          ),
          SizedBox(
            height: 7.h,
          ),
          // Text(
          //   'Provid us with your Date of Birth',
          //   textAlign: TextAlign.center,
          //   style: TextStyle(
          //       color: const Color(0xFF19a9e5),
          //       fontFamily: 'Poppins',
          //       fontSize: ScUtil().setSp(12),
          //       letterSpacing: 1.5,
          //       fontWeight: FontWeight.bold,
          //       height: 1.16),
          // ),
          Text(
            'Provide us with your Date of Birth',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: const Color.fromRGBO(109, 110, 113, 1),
                fontFamily: 'Poppins',
                fontSize: ScUtil().setSp(18),
                letterSpacing: 0,
                fontWeight: FontWeight.bold,
                height: 1.20),
          ),

          SizedBox(
            height: 3.h,
          ),
          ValueListenableBuilder(
              valueListenable: isDateSelected,
              builder: (_, v, __) {
                return Padding(
                  padding: const EdgeInsets.only(left: 30, right: 30),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                      elevation: 0.0,
                    ),
                    onPressed: () {
                      DatePicker.showDatePicker(context,
                          theme: const DatePickerTheme(
                            itemStyle: TextStyle(
                              color: Colors.black,
                            ),
                            cancelStyle: TextStyle(),
                            doneStyle: TextStyle(),
                            containerHeight: 210,
                          ),
                          showTitleActions: true,
                          minTime: DateTime(1900, 1, 1),
                          maxTime: DateTime.now(), onConfirm: (DateTime date) {
                        String updatedDt = newFormat.format(date);
                        SelectedDate.value = updatedDt;

                        //"${date.toLocal()}".split(' ')[0];
                        isDateSelected.value = true;
                      }, currentTime: DateTime.now(), locale: LocaleType.en);
                    },
                    child: Container(
                      alignment: Alignment.center,
                      height: 70.0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Container(
                                child: Row(
                                  children: <Widget>[
                                    const Icon(
                                      Icons.date_range,
                                      size: 18.0,
                                      color: Color(0xFF19a9e5),
                                    ),
                                    v
                                        ? ValueListenableBuilder(
                                            valueListenable: SelectedDate,
                                            builder: (_, s, __) {
                                              return Text(
                                                s,
                                                style: TextStyle(
                                                    color: const Color(0xFF19a9e5),
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: ScUtil().setSp(18)),
                                              );
                                            })
                                        : Text(
                                            'Not set',
                                            style: TextStyle(
                                                color: const Color(0xFF19a9e5),
                                                fontWeight: FontWeight.bold,
                                                fontSize: ScUtil().setSp(18)),
                                          ),
                                  ],
                                ),
                              )
                            ],
                          ),
                          Text(
                            "  Change",
                            style: TextStyle(
                                color: const Color(0xFF19a9e5),
                                fontWeight: FontWeight.bold,
                                fontSize: ScUtil().setSp(18)),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
          SizedBox(
            height: 10.h,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: GestureDetector(
                onTap: () async {
                  if (isDateSelected.value) {
                    if (isAdult(SelectedDate.value)) {
                      saveData.dob = SelectedDate.value;
                      final SharedPreferences prefs = await SharedPreferences.getInstance();
                      prefs.setString('DobM', SelectedDate.value.toString());
                      Get.to(MobileNumberScreen(isSSo: prefs.getBool('isSSoUser') ?? false));
                    } else {
                      Get.showSnackbar(
                        const GetSnackBar(
                          title: "Invalid Date",
                          message:
                              'Attention! You need to be 13 years or older to register with hCare.',
                          backgroundColor: AppColors.primaryAccentColor,
                          duration: Duration(seconds: 3),
                        ),
                      );
                    }
                  } else {
                    Get.showSnackbar(
                      const GetSnackBar(
                        title: "Invalid Date",
                        message: 'Date Not Selected',
                        backgroundColor: AppColors.primaryAccentColor,
                        duration: Duration(seconds: 3),
                      ),
                    );
                  }
                },
                child: Container(
                    decoration: BoxDecoration(
                        color: AppColors.primaryAccentColor,
                        borderRadius: BorderRadius.circular(5)),
                    height: 5.h,
                    width: 30.w,
                    child: const Center(
                        child: Text(
                      ' NEXT ',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    )))),
          ),
        ],
      ),
    );
  }

  bool isAdult(String birthDateString) {
    String datePattern = "MM/dd/yyyy";

    // Current time - at this moment
    DateTime today = DateTime.now();

    // Parsed date to check
    DateTime birthDate = DateFormat(datePattern).parse(birthDateString);

    // Date to check but moved 13 years + 3 leap days ahead
    DateTime adultDate = DateTime(
      birthDate.year + 13,
      birthDate.month,
      birthDate.day + 3,
    );

    return adultDate.isBefore(today);
  }
}
