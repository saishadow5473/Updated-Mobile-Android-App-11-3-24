import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../app/utils/appColors.dart';
import '../functionalities/draft_data.dart';
import '../widgets/height.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import 'WeightScreen.dart';

class HeightScreen extends StatefulWidget {
  const HeightScreen({Key key}) : super(key: key);

  @override
  State<HeightScreen> createState() => _HeightScreenState();
}

class _HeightScreenState extends State<HeightScreen> {
  List<int> itemListft = List.generate(10, (int index) => 1 * index);
  List<int> itemListin = List.generate(13, (int index) => 1 * index);
  final PageController _pageController = PageController(initialPage: 5, viewportFraction: 1);
  final PageController _pageController1 = PageController(initialPage: 6, viewportFraction: 1);
  int selectedft = 5;
  int selectedin = 3;
  int selectedfromCms = 160;
  bool lastActiveIsCms = true;
  DraftData saveData = DraftData();

  @override
  Widget build(BuildContext context) {
    print(MediaQuery.of(context).size.height);
    itemListft.remove(0);
    itemListin.remove(0);
    selectedft = itemListft.first;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryAccentColor,
        title: const Text(
          'Choose your Height',
        ),
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
            height: 4.h,
          ),
          Container(
            height: 22.h,
            width: 100.w,
            decoration: const BoxDecoration(
                image: DecorationImage(image: AssetImage('newAssets/images/height.png'))),
          ),
          SizedBox(
            height: 3.h,
          ),
          Text(
            'Choose your Height',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: 16.sp),
          ),
          Stack(
            children: [
              SizedBox(
                height:MediaQuery.of(context).size.height<700? 24.5.h:22.h,
                child: HeightSlider(
                  weight: selectedfromCms,
                  minWeight: 60,
                  maxWeight: 273,
                  onChange: (int val) {
                    setState(() {
                      selectedfromCms = val;
                      lastActiveIsCms = true;

                      print(selectedfromCms);
                    });
                  },
                ),
              ),
              Positioned(
                top: 38.sp,
                right: 14.6.sp,
                child: Text(
                  'Cms',
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15.4.sp),
                ),
              ),
            ],
          ),
          const Text('OR'),
          SizedBox(
            height: 4.h,
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              height:MediaQuery.of(context).size.height<700? 8.2.h:7.h,
              width: 30.w,
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
                  SizedBox(
                    width: 20.w,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 2.h, left: 2.w),
                          child: SizedBox(
                            height: 7.h,
                            width: 6.w,
                            child: PageView.builder(
                                controller: _pageController,
                                scrollDirection: Axis.vertical,
                                itemBuilder: (BuildContext context, int index) {
                                  selectedft = itemListft[index];
                                  return Text(itemListft[index].toString());
                                }),
                          ),
                        ),
                        Column(
                          children: [
                            GestureDetector(
                                onTap: () {
                                  if (selectedft < 9) {
                                    _pageController.nextPage(
                                        duration: const Duration(milliseconds: 60),
                                        curve: Curves.bounceOut);
                                  }
                                  lastActiveIsCms = false;
                                  setState(() {});
                                },
                                child: const Icon(Icons.arrow_drop_up_outlined)),
                            SizedBox(
                              height: 1.h,
                            ),
                            GestureDetector(
                                onTap: () {
                                  //set the limitation
                                  setState(() {
                                    lastActiveIsCms = false;
                                    _pageController.previousPage(
                                        duration: const Duration(milliseconds: 60),
                                        curve: Curves.bounceOut);
                                  });
                                },
                                child: const Icon(Icons.arrow_drop_down_outlined))
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                     height:MediaQuery.of(context).size.height<700? 8.2.h:7.h,
                      color: Colors.grey.shade200,
                      width: 10.w,
                      child: const Center(child: Text('Ft'))),
                ],
              ),
            ),
            SizedBox(
              width: 6.w,
            ),
            Container(
              height:MediaQuery.of(context).size.height<700? 8.2.h:7.h,
              width: 30.w,
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
                  SizedBox(
                    width: 20.w,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 2.h, left: 2.w),
                          child: SizedBox(
                            height: 7.h,
                            width: 6.w,
                            child: PageView.builder(
                                controller: _pageController1,
                                scrollDirection: Axis.vertical,
                                itemBuilder: (BuildContext context, int index) {
                                  selectedin = itemListin[index];
                                  return Text(itemListin[index].toString());
                                }),
                          ),
                        ),
                        Column(
                          children: [
                            GestureDetector(
                                onTap: () {
                                  lastActiveIsCms = false;
                                  if (selectedin < 12) {
                                    setState(() {
                                      _pageController1.nextPage(
                                          duration: const Duration(milliseconds: 60),
                                          curve: Curves.bounceOut);
                                    });
                                  }
                                },
                                child: const Icon(Icons.arrow_drop_up_outlined)),
                            SizedBox(
                              height: 1.h,
                            ),
                            GestureDetector(
                                onTap: () {
                                  _pageController1.previousPage(
                                      duration: const Duration(milliseconds: 60),
                                      curve: Curves.bounceOut);
                                  lastActiveIsCms = false;
                                  //set the limitation
                                },
                                child: const Icon(Icons.arrow_drop_down_outlined))
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                      height:MediaQuery.of(context).size.height<700? 8.2.h:7.h,
                      color: Colors.grey.shade200,
                      width: 10.w,
                      child: const Center(child: Text('In'))),
                ],
              ),
            )
          ]),
          SizedBox(
            height: 10.h,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: GestureDetector(
                onTap: () async {
                  print(lastActiveIsCms);
                  print('$selectedft  $selectedin');

                  final SharedPreferences prefs = await SharedPreferences.getInstance();
                  if (lastActiveIsCms) {
                    print(selectedfromCms.toString());
                    prefs.setString('HeightM', (selectedfromCms / 100).toString());
                  } else {
                    double heightinmeters = convertToMeters(selectedft, selectedin);
                    prefs.setString('HeightM', heightinmeters.toStringAsFixed(2));
                  }
                  print(selectedfromCms.toString());
                  Get.to(const WeightScreen());
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

  double convertToMeters(int feet, int inches) {
    int totalInches = (feet * 12) + inches;
    double meters = totalInches * 0.0254; // 1 inch = 0.0254 meters
    return meters;
  }
}
