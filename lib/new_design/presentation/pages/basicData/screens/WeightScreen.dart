import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../functionalities/draft_data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../app/utils/appColors.dart';
import '../screens/DobScreen.dart';
import '../widgets/height.dart';

import 'package:responsive_sizer/responsive_sizer.dart';

class WeightScreen extends StatefulWidget {
  const WeightScreen({Key key}) : super(key: key);

  @override
  State<WeightScreen> createState() => _WeightScreenState();
}

class _WeightScreenState extends State<WeightScreen> {
  DraftData saveData = DraftData();
  String selected = '70';
  int intValue = 70;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryAccentColor,
        title: const Text('Choose your Weight'),
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
                image: DecorationImage(image: AssetImage('newAssets/images/Weight.png'))),
          ),
          SizedBox(
            height: 6.h,
          ),
          Text(
            'Choose your Weight',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: 16.5.sp),
          ),
          // SizedBox(height: 22.h, width: 36.h, child: Text('hdbus')),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
            Stack(children: [
              SizedBox(
                height:MediaQuery.of(context).size.height<700? 24.5.h:22.h,
                width: 80.w,
                child: HeightSlider(
                  weight: intValue,
                  minWeight: 40,
                  maxWeight: 250,
                  onChange: (int val) {
                    setState(() {
                      selected = val.toString();
                      intValue = int.parse(val.toString());

                      // print(selected);
                    });
                  },
                ),
              ),
              Positioned(
                top: 37.sp,
                right: 20.sp,
                child: Text(
                  'Kg',
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16.5.sp),
                ),
              ),
            ]),
          ]),
          SizedBox(
            height: 6.h,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: GestureDetector(
                onTap: () async {
                  final SharedPreferences prefs = await SharedPreferences.getInstance();
                  print(selected);
                  prefs.setString('WeightM', selected.toString());
                  Get.to(const DobScreen());
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
}
