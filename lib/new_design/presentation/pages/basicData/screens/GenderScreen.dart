import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../app/utils/appColors.dart';
import '../functionalities/draft_data.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import 'HeightScreen.dart';

class GenderSelectScreen extends StatelessWidget {
  GenderSelectScreen({Key key}) : super(key: key);

  ValueNotifier<bool> isMaleActive = ValueNotifier<bool>(true);
  DraftData saveData = DraftData();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryAccentColor,
        title: const Text('Choose your Gender'),
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
                image: DecorationImage(image: AssetImage('newAssets/images/gender.png'))),
          ),
          SizedBox(
            height: 6.h,
          ),
          Text(
            'Choose your Gender',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: 16.sp),
          ),
          SizedBox(
            height: 4.h,
          ),
          ValueListenableBuilder(
              valueListenable: isMaleActive,
              builder: (_, val, __) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        isMaleActive.value = true;
                      },
                      child: Container(
                        height: 7.h,
                        width: 34.w,
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
                        child: Row(
                          children: [
                            val
                                ? Container(
                                    height: 2.h,
                                    width: 10.w,
                                    decoration: const BoxDecoration(
                                        color: Colors.blue, shape: BoxShape.circle),
                                  )
                                : Container(
                                    height: 2.h,
                                    width: 10.w,
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.blue,
                                        ),
                                        shape: BoxShape.circle),
                                  ),
                            SizedBox(
                              width: 1.w,
                            ),
                            Text(
                              'Male',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.sp),
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 5.w,
                    ),
                    GestureDetector(
                      onTap: () {
                        isMaleActive.value = false;
                      },
                      child: Container(
                        height: 6.h,
                        width: 34.w,
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
                        child: Row(
                          children: [
                            !val
                                ? Container(
                                    height: 2.h,
                                    width: 12.w,
                                    decoration: const BoxDecoration(
                                        color: Colors.blue, shape: BoxShape.circle),
                                  )
                                : Container(
                                    height: 2.h,
                                    width: 12.w,
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.blue,
                                        ),
                                        shape: BoxShape.circle),
                                  ),
                            SizedBox(
                              width: 1.w,
                            ),
                            Text(
                              'Female',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.sp),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }),
          SizedBox(
            height: 22.h,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: GestureDetector(
                onTap: () async {
                  saveData.gender = isMaleActive.value ? 'm' : 'f';
                  final SharedPreferences prefs = await SharedPreferences.getInstance();
                  prefs.setString('GenderM', isMaleActive.value ? 'm' : 'f');
                  Get.to(const HeightScreen());
                },
                child: Container(
                    decoration: BoxDecoration(
                        color: AppColors.primaryAccentColor,
                        borderRadius: BorderRadius.circular(5)),
                    height: 5.h,
                    width: 30.w,
                    child: Center(
                        child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        ' NEXT ',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    )))),
          ),
        ],
      ),
    );
  }
}
