import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../constants/spKeys.dart';
import '../../../../models/checkInternet.dart';
import '../../../app/utils/appColors.dart';
import '../dashboard/common_screen_for_navigation.dart';
import '../../../../repositories/api_repository.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChangePasswordNew extends StatefulWidget {
  const ChangePasswordNew({Key key}) : super(key: key);

  @override
  State<ChangePasswordNew> createState() => _ChangePasswordNewState();
}

class _ChangePasswordNewState extends State<ChangePasswordNew> {
  ValueNotifier<TextEditingController> newPasswordController =
      ValueNotifier<TextEditingController>(TextEditingController(text: ''));
  ValueNotifier<TextEditingController> confirmPasswordController =
      ValueNotifier<TextEditingController>(TextEditingController(text: ''));
  ValueNotifier<TextEditingController> oldPasswordController =
      ValueNotifier<TextEditingController>(TextEditingController(text: ''));

  ValueNotifier<bool> eightChars = ValueNotifier(false);
  ValueNotifier<bool> specialChar = ValueNotifier(false);
  ValueNotifier<bool> upperCaseChar = ValueNotifier(false);
  ValueNotifier<bool> number = ValueNotifier(false);
  final Apirepository _apirepository = Apirepository();
  String correct = '';
  String email = '';
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<String> getEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Object data = prefs.get(SPKeys.userData);

    data = data == null || data == '' ? '{"User":{}}' : data;

    Map res = jsonDecode(data);
    correct = prefs.get(SPKeys.password);
    return res['User']['email'];
  }

  getData() async {
    email = await getEmail();
  }

  @override
  void initState() {
    getEmail();
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CommonScreenForNavigation(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Change Password'),
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
      content: Container(
        height: 100.h,
        color: Colors.white,
        child: SafeArea(
            child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 1.h,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 22.h,
                      width: 100.w,
                      decoration: const BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage('assets/images/Change Password.png'))),
                    ),
                    SizedBox(
                      height: 1.h,
                    ),
                    Container(
                      padding: EdgeInsets.only(left: 4.w, right: 7.w),
                      child: Column(
                        children: const [
                          Text('Enter Old Password',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              )),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 2.h,
                    ),
                    Container(
                      padding: EdgeInsets.only(left: 4.w, right: 7.w),
                      child: TextFormField(
                        obscureText: true,
                        validator: (String value) {
                          if (value.isEmpty) {
                            return 'Password field cannot be blank.';
                          }
                        },
                        controller: oldPasswordController.value,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(borderSide: BorderSide(width: 1))),
                      ),
                    ),
                    SizedBox(
                      height: 2.h,
                    ),
                    Container(
                      padding: EdgeInsets.only(left: 4.w, right: 7.w),
                      child: Column(
                        children: const [
                          Text('Enter New Password',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              )),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 2.h,
                    ),
                    Container(
                      padding: EdgeInsets.only(left: 4.w, right: 7.w),
                      child: TextFormField(
                        obscureText: true,
                        validator: (String value) {
                          if (!(value.length >= 8)) {
                            return 'Password must include min. 8 characters.';
                          }
                          if (!(value.isNotEmpty && !value.contains(RegExp(r'^[\w&.-]+$'), 0))) {
                            return 'Password should have a special character';
                          }
                          if (!(value.contains(RegExp(r'[A-Z]'), 0))) {
                            return 'Password should have a capital letter.[A-Z]';
                          }
                          if (!(value.contains(RegExp(r'\d'), 0))) {
                            return 'Password must include at least 1 numeral between 0-9.';
                          }
                        },
                        controller: newPasswordController.value,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(borderSide: BorderSide(width: 1))),
                      ),
                    ),
                    SizedBox(
                      height: 2.h,
                    ),
                    Container(
                      padding: EdgeInsets.only(left: 4.w, right: 7.w),
                      child: Column(
                        children: const [
                          Text('Confirm Password',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              )),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 2.h,
                    ),
                    Container(
                      padding: EdgeInsets.only(left: 4.w, right: 7.w),
                      child: TextFormField(
                        obscureText: true,
                        validator: (String value) {
                          if (newPasswordController.value.text != value) {
                            return 'Both the Passwords does not match';
                          }
                        },
                        controller: confirmPasswordController.value,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(borderSide: BorderSide(width: 1))),
                      ),
                    ),
                    SizedBox(
                      height: 2.h,
                    ),
                    Center(
                      child: GestureDetector(
                        onTap: () async {
                          print('clicked');
                          if (_formKey.currentState.validate()) {
                            await _change();
                          }
                        },
                        child: Container(
                          height: 4.6.h,
                          width: 35.w,
                          decoration: const BoxDecoration(
                            color: AppColors.ihlPrimaryColor,
                          ),
                          child: const Center(
                            child: Text('CONFIRM',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 15,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                )),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        )),
      ),
    );
  }

  Future<String> _change() async {
    //FocusScope.of(context).unfocus();
    bool connection = await checkInternet();
    if (connection == false) {
      SnackBar snackBar = const SnackBar(
        content: Text('No internet connection. Please check and try again.'),
        backgroundColor: Colors.amber,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return null;
    }
    if (email == null || email == '') {
      SnackBar snackBar = const SnackBar(
        content: Text('Please try again in a few moments.'),
        backgroundColor: Colors.amber,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return 'Please try again in a few moments.';
    }

    if (correct != oldPasswordController.value.text && correct != null && correct != '') {
      SnackBar snackBar = const SnackBar(
        content: Text('Please enter the correct old password.'),
        backgroundColor: Colors.red,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return 'Please enter the correct old password.';
    }
    if (oldPasswordController.value.text == newPasswordController.value.text) {
      SnackBar snackBar = const SnackBar(
        content: Text('Old and new password shouldn\'t be same'),
        backgroundColor: Colors.red,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return 'Please enter the correct old password.';
    }

    SnackBar snackBar = const SnackBar(
      content: Text('Updating Password.....'),
      backgroundColor: Colors.amber,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);

    _apirepository
        .userProfileResetPasswordAPI(
            email: email,
            newPassword: newPasswordController.value.text,
            password: oldPasswordController.value.text)
        .then((String value) {
      if (value == 'wrong old password') {
        SnackBar snackBarx = const SnackBar(
          content: Text('Wrong old password'),
          backgroundColor: Colors.red,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBarx);
        Get.back();
      }
      if (value == 'success') {
        SnackBar snackBar1 = const SnackBar(
          content: Text('Password Succesfully Updated'),
          backgroundColor: Colors.green,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar1);
        Get.back();
      } else {
        SnackBar snackBary = const SnackBar(
          content: Text('Something went wrong'),
          backgroundColor: Colors.red,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBary);
        Get.back();
      }
    }).catchError((onError) {
      SnackBar snackBar = SnackBar(
        content: Text('Failed to Update Password:$onError'),
        backgroundColor: Colors.red,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    });
  }
}
