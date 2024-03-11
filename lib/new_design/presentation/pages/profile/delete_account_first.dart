import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../constants/spKeys.dart';
import 'delete_account_third.dart';
import '../../../app/utils/appColors.dart';
import '../dashboard/common_screen_for_navigation.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class DeleteScreeenFirst extends StatefulWidget {
  const DeleteScreeenFirst({Key key}) : super(key: key);

  @override
  State<DeleteScreeenFirst> createState() => _DeleteScreeenFirstState();
}

class _DeleteScreeenFirstState extends State<DeleteScreeenFirst> {
  Future<String> getEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Object data = prefs.get(SPKeys.userData);

    data = data == null || data == '' ? '{"User":{}}' : data;

    Map res = jsonDecode(data);

    return res['User']['email'];
  }

  Future<String> getAlternate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Object data = prefs.get(SPKeys.userData);

    data = data == null || data == '' ? '{"User":{}}' : data;

    Map res = jsonDecode(data);
  }

  @override
  Widget build(BuildContext context) {
    return CommonScreenForNavigation(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const Text('Others'),
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
      content: SafeArea(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        // mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 10.h,
          ),
          const Text('OTHER ACCOUNT SETTINGS',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 15,
                fontWeight: FontWeight.w500,
              )),
          SizedBox(
            height: 4.5.h,
          ),
          Container(
            height: 32.h,
            width: 100.w,
            decoration: const BoxDecoration(
                image:
                    DecorationImage(image: AssetImage('assets/images/Other Account Settings.png'))),
          ),
          SizedBox(
            height: 4.5.h,
          ),
          SizedBox(
            height: 6.h,
          ),
          Container(
            padding: EdgeInsets.only(left: 10.w, right: 10.w),
            child: GestureDetector(
              onTap: () async {
                String email = await getEmail();
                Get.to(DeleteScreeenThird(
                  email: email,
                ));
              },
              child: Container(
                height: 4.h,
                width: 60.w,
                decoration: const BoxDecoration(
                  color: AppColors.ihlPrimaryColor,
                ),
                child: const Center(
                  child: Text('DELETE MY ACCOUNT',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 15,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      )),
                ),
              ),
            ),
          )
        ],
      )),
    );
  }
}
