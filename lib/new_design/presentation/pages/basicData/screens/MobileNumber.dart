import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../app/utils/appColors.dart';
import '../functionalities/draft_data.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import 'AlternateEmail.dart';
import 'OtpVerificationScreen.dart';

bool mobileSkipped = false;

class MobileNumberScreen extends StatefulWidget {
  bool isSSo;

  MobileNumberScreen({Key key, this.isSSo}) : super(key: key);

  @override
  State<MobileNumberScreen> createState() => _MobileNumberScreenState();
}

class _MobileNumberScreenState extends State<MobileNumberScreen> {
  DraftData saveData = DraftData();

  TextEditingController mobileNumber = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryAccentColor,
        title: const Text('Mobile Number'),
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
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 18.sp, vertical: 18.sp),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 9.h,
              ),
              Container(
                height: 24.h,
                width: 100.w,
                decoration: const BoxDecoration(
                    image: DecorationImage(image: AssetImage('newAssets/images/dialpad.png'))),
              ),
              SizedBox(
                height: 8.h,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Mobile Number',
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16.5.sp),
                  ),
                  SizedBox(
                    width: 39.w,
                  ),
                  widget.isSSo
                      ? GestureDetector(
                          onTap: () async {
                            final SharedPreferences prefs = await SharedPreferences.getInstance();
                            mobileSkipped = true;
                            Get.to(AlternateEmailScreen(isSSo: prefs.getBool('isSSoUser')));
                          },
                          child: Center(
                              child: Text(
                            ' SKIP ',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 16.5.sp),
                          )))
                      : const SizedBox(),
                  widget.isSSo
                      ? const Icon(
                          Icons.arrow_right_alt,
                          color: Colors.black,
                        )
                      : const SizedBox()
                ],
              ),
              SizedBox(
                height: 3.h,
              ),
              TextFormField(
                maxLength: 10,
                controller: mobileNumber,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Enter your mobile number'),
              ),
              SizedBox(
                height: 5.h,
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: GestureDetector(
                    onTap: () async {
                      if (mobileNumber.text.length > 9) {
                        mobileSkipped = false;
                        final SharedPreferences prefs = await SharedPreferences.getInstance();
                        prefs.setString('MobileM', mobileNumber.text);
                        Get.to(OtpVerificationScreen(
                          mobileNumber: mobileNumber.text,
                          fromAlternateEmail: false,
                        ));
                      } else {
                        Get.showSnackbar(
                          const GetSnackBar(
                            title: "Error Occured",
                            message: "Invalid Phone Number",
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
        ),
      ),
    );
  }
}
