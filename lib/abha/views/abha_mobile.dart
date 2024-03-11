import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ihl/abha/networks/network_calls_abha.dart';
import 'package:ihl/abha/views/abha_otp.dart';
import 'package:ihl/constants/app_texts.dart';
import 'package:ihl/constants/routes.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:sizer/sizer.dart';

class AbhaMobileLogin extends StatefulWidget {
  const AbhaMobileLogin({Key key}) : super(key: key);

  @override
  State<AbhaMobileLogin> createState() => _AbhaMobileLoginState();
}

class _AbhaMobileLoginState extends State<AbhaMobileLogin> {
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    TextEditingController aadhaarMobile = new TextEditingController();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        title: Padding(
          padding: const EdgeInsets.only(left: 20),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              height: 5,
              child: LinearProgressIndicator(
                value: 0.5, // percent filled
                backgroundColor: Color(0xffDBEEFC),
              ),
            ),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Get.back();
          },
          color: Colors.black,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {},
            child: Text(AppTexts.next,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  fontSize: 15.sp,
                )),
            style: TextButton.styleFrom(
                shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
                textStyle: TextStyle(color: Color(0xFF19a9e5))),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 5.0,
            ),
            Center(
                child: Text(
              'STEP 4/9',
              style: TextStyle(
                color: AppColors.primaryColor,
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
              ),
            )),
            SizedBox(
              height: 5.h,
            ),
            Container(
              padding: EdgeInsets.fromLTRB(42.0.sp, 32.sp, 36.sp, 22.sp),
              child: Text('Provide us your Aadhar related mobile number',
                  maxLines: 3,
                  style: TextStyle(
                      fontSize: 18.sp,
                      fontFamily: 'Poppins',
                      color: Color.fromRGBO(74, 75, 77, 1),
                      fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: EdgeInsets.all(20.sp),
              child: TextFormField(
                controller: aadhaarMobile,
                keyboardType: TextInputType.visiblePassword,
                autocorrect: true,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: 18.sp, horizontal: 28.sp),
                  labelText: "Mobile number (optional)",
                  fillColor: Colors.white24,
                  border: new OutlineInputBorder(
                      borderRadius: new BorderRadius.circular(15.0),
                      borderSide: new BorderSide(color: Colors.blueGrey)),
                ),
                maxLines: 1,
                style: TextStyle(fontSize: 16.0),
                textInputAction: TextInputAction.done,
              ),
            ),
            GestureDetector(
              onTap: () {
                abhaSkipped = true;
                Navigator.of(context).pushNamed(Routes.Sdob);
              },
              child: Padding(
                padding: EdgeInsets.all(17.sp),
                child: Align(
                  alignment: Alignment.topRight,
                  child: Text(
                    'Skip & Proceed',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontFamily: 'Poppins',
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 35.sp,
            ),
            GestureDetector(
              onTap: () async {
                setState(() {
                  isLoading = true;
                });
                final box = GetStorage();
                box.write("mobileNumber", aadhaarMobile.text);
                String userExistenceCheck =
                    await NetworkCallsAbha().checkAbhaUserOrnot(aadhaarMobile.text);
                if (userExistenceCheck == 'success') {
                  setState(() {
                    isLoading = false;
                  });
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: ((context) => AbhaOtpScreen(
                                screen: "aadharUserCheck" + "+" + aadhaarMobile.text,
                              ))));
                } else {
                  var mobile = box.read("userMobileNumber");
                  // var reponse1 = await NetworkCallsAbha().generateMobileOtp(aadhaarMobile.text);
                  // var response =
                  //     await NetworkCallsAbha().checkAndGenerateMobileOtp(aadhaarMobile.text);
                  var reponse1 = await NetworkCallsAbha().generateMobileOtp(mobile);
                  var response = await NetworkCallsAbha().checkAndGenerateMobileOtp(mobile);
                  if (response == 'success') {
                    setState(() {
                      isLoading = false;
                    });
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: ((context) => AbhaOtpScreen(
                                  screen: "mobile",
                                ))));
                  }
                }
                setState(() {
                  isLoading = false;
                });
              },
              child: Container(
                height: 6.5.h,
                width: 55.w,
                decoration: BoxDecoration(
                    color: Color(0xFF19a9e5), borderRadius: BorderRadius.circular(10.sp)),
                child: Center(
                    child: !isLoading
                        ? Text(
                            'Continue',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontFamily: 'Poppins',
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : CircularProgressIndicator(
                            color: Colors.white,
                          )),
              ),
            )
          ],
        ),
      ),
    );
  }
}
