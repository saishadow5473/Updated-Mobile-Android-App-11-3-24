import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../utils/SpUtil.dart';
import '../changePassword/changePassword.dart';
import '../dashboard/common_screen_for_navigation.dart';
import '../profile/delete_account_first.dart';
import '../profile/myprofile.dart';
import '../../../../widgets/profileScreen/exports.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isSso = false;
  @override
  void initState() {
    _isSso = SpUtil.getBool('isSSoUser') ?? false;

    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CommonScreenForNavigation(
      appBar: AppBar(
        title: const Text('Settings'),
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
        color: Colors.white,
        child: SafeArea(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 7.h,
            ),
            Container(
              height: 20.h,
              width: 100.w,
              decoration: const BoxDecoration(
                  image: DecorationImage(image: AssetImage('assets/images/Settings.png'))),
            ),
            SizedBox(
              height: 6.h,
            ),
            GestureDetector(
              onTap: () {
                Get.to(const MyProfile());
              },
              child: Container(
                height: 8.h,
                width: 90.w,
                padding: EdgeInsets.only(top: 2.7.h, left: 4.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      blurRadius: 4,
                      offset: const Offset(4, 8), // Shadow position
                    ),
                    BoxShadow(
                      color: Colors.grey.shade300,
                      blurRadius: 4,
                      offset: const Offset(-3, 8), // Shadow position
                    ),
                    BoxShadow(
                      color: Colors.grey.shade300,
                      blurRadius: 4,
                      offset: const Offset(0, -2), // Shadow position
                    ),
                  ],
                ),
                child: const Text('Profile Settings',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    )),
              ),
            ),
            Visibility(
              visible: !_isSso,
              child: SizedBox(
                height: 4.h,
              ),
            ),
            Visibility(
              visible: !_isSso,
              child: GestureDetector(
                onTap: () {
                  Get.to(const ChangePasswordNew());
                },
                child: Container(
                  height: 8.h,
                  width: 90.w,
                  padding: EdgeInsets.only(top: 2.7.h, left: 4.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade400,
                        blurRadius: 4,
                        offset: const Offset(4, 8), // Shadow position
                      ),
                      BoxShadow(
                        color: Colors.grey.shade400,
                        blurRadius: 4,
                        offset: const Offset(-3, 8), // Shadow position
                      ),
                      BoxShadow(
                        color: Colors.grey.shade400,
                        blurRadius: 4,
                        offset: const Offset(0, -2), // Shadow position
                      ),
                    ],
                  ),
                  child: const Text('Change Password',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      )),
                ),
              ),
            ),
            Visibility(
              visible: !_isSso,
              child: SizedBox(
                height: 4.h,
              ),
            ),
            Visibility(
              visible: !_isSso,
              child: GestureDetector(
                onTap: () {
                  Get.to(const DeleteScreeenFirst());
                },
                child: Container(
                  height: 8.h,
                  width: 90.w,
                  padding: EdgeInsets.only(top: 2.7.h, left: 4.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade400,
                        blurRadius: 4,
                        offset: const Offset(4, 8), // Shadow position
                      ),
                      BoxShadow(
                        color: Colors.grey.shade400,
                        blurRadius: 4,
                        offset: const Offset(-3, 8), // Shadow position
                      ),
                      BoxShadow(
                        color: Colors.grey.shade400,
                        blurRadius: 4,
                        offset: const Offset(0, -2), // Shadow position
                      ),
                    ],
                  ),
                  child: const Text('Others',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      )),
                ),
              ),
            )
          ],
        )),
      ),
    );
  }
}
