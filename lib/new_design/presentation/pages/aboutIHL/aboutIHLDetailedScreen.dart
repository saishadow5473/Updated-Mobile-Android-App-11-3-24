import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ihl/new_design/presentation/pages/dashboard/common_screen_for_navigation.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class AboutDetailedScreeen extends StatefulWidget {
  const AboutDetailedScreeen({Key key, @required this.title, @required this.content})
      : super(key: key);
  final String title, content;
  @override
  State<AboutDetailedScreeen> createState() => _AboutDetailedScreeenState();
}

class _AboutDetailedScreeenState extends State<AboutDetailedScreeen> {
  @override
  Widget build(BuildContext context) {
    return CommonScreenForNavigation(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.keyboard_arrow_left,
            size: 28.sp,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      content: Column(
        children: [
          SizedBox(
            height: 80.h,
            child: SingleChildScrollView(
              child: Container(
                decoration: const BoxDecoration(

                    // boxShadow: [
                    //   // BoxShadow(
                    //   //   color: Colors.grey.shade300,
                    //   //   blurRadius: 4,
                    //   //   offset: const Offset(4, 8), // Shadow position
                    //   // ),
                    //   BoxShadow(
                    //     color: Colors.grey.shade300,
                    //     blurRadius: 4,
                    //     offset: const Offset(-3, 8), // Shadow position
                    //   ),
                    //   BoxShadow(
                    //     color: Colors.grey.shade300,
                    //     blurRadius: 4,
                    //     offset: const Offset(0, -2), // Shadow position
                    //   ),
                    // ],
                    ),
                padding: EdgeInsets.only(top: 3.h, left: 5.w, right: 5.w, bottom: 8.h),
                child: Text(widget.content,
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        color: const Color.fromARGB(255, 48, 48, 48),
                        fontSize: 16.5.sp,
                        letterSpacing: 0.2,
                        fontWeight: FontWeight.w300)),
              ),
            ),
          )
        ],
      ),
    );
  }
}
