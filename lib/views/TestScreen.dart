import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ihl/painters/backgroundPanter.dart';

import 'package:ihl/utils/app_colors.dart';
import 'package:lottie/lottie.dart';
import 'package:timeline_tile/timeline_tile.dart';

class TestScreen extends StatefulWidget {
  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  int _selectedImage = 0;
  List<String> _imageUrls = [
    'https://assets5.lottiefiles.com/packages/lf20_uZq6rF.json',
    'https://assets3.lottiefiles.com/private_files/lf30_rzhdjuoe.json',
    'https://assets2.lottiefiles.com/private_files/lf30_iakyfsf7.json',
    'https://assets4.lottiefiles.com/temp/lf20_Th7CEA.json',
  ];
  bool _2ndBox = false, _3rdBox = false, _4thBox = false;
  @override
  void initState() {
    Timer.periodic(Duration(seconds: 3), (timer) {
      if (_selectedImage == _imageUrls.length - 1) {
        timer.cancel();
      } else {
        _selectedImage++;
      }
      switch (_selectedImage) {
        case 1:
          setState(() => _2ndBox = true);
          break;
        case 2:
          setState(() => _3rdBox = true);
          break;
        case 3:
          setState(() => _4thBox = true);
          break;
        default:
          setState(() => _4thBox = false);
      }
    });
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.grey[100],
        child: Column(
          children: <Widget>[
            CustomPaint(
              painter: BackgroundPainter(
                primary: AppColors.primaryColor.withOpacity(0.7),
                secondary: AppColors.primaryColor.withOpacity(0.0),
              ),
              child: Container(),
            ),
            SizedBox(
              height: 20,
            ),
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 30.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(
                      Radius.circular(30),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 30.0),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          SizedBox(
                            height: 20,
                          ),
                          TimelineTile(
                            alignment: TimelineAlign.center,
                            isFirst: true,
                            indicatorStyle: IndicatorStyle(
                              width: 30,
                              color: Colors.green,
                              padding: const EdgeInsets.all(8),
                              iconStyle: IconStyle(
                                color: Colors.white,
                                iconData: Icons.check,
                              ),
                            ),
                            beforeLineStyle: LineStyle(
                              color: Colors.green,
                              thickness: 3,
                            ),
                            startChild: Card(
                              margin: EdgeInsets.symmetric(vertical: 26.0),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0)),
                              clipBehavior: Clip.antiAlias,
                              color: Colors.green[300],
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  'Checking Profile',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                          TimelineTile(
                            alignment: TimelineAlign.center,
                            indicatorStyle: IndicatorStyle(
                              width: 30,
                              color: _2ndBox ? Colors.green : Colors.grey,
                              padding: const EdgeInsets.all(8),
                              iconStyle: IconStyle(
                                color: Colors.white,
                                iconData: Icons.check,
                              ),
                            ),
                            beforeLineStyle: LineStyle(
                              color: _2ndBox ? Colors.green : Colors.grey,
                              thickness: 3,
                            ),
                            endChild: Card(
                              margin: EdgeInsets.symmetric(vertical: 26.0),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0)),
                              clipBehavior: Clip.antiAlias,
                              color: _2ndBox
                                  ? Colors.green[300]
                                  : Colors.amber[100],
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  'Updating Email..!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                          TimelineTile(
                            alignment: TimelineAlign.center,
                            indicatorStyle: IndicatorStyle(
                              width: 30,
                              color: _3rdBox ? Colors.green : Colors.grey,
                              padding: const EdgeInsets.all(8),
                              iconStyle: IconStyle(
                                color: Colors.white,
                                iconData: Icons.check,
                              ),
                            ),
                            beforeLineStyle: LineStyle(
                              color: _3rdBox ? Colors.green : Colors.grey,
                              thickness: 3,
                            ),
                            startChild: Card(
                              margin: EdgeInsets.symmetric(vertical: 26.0),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0)),
                              clipBehavior: Clip.antiAlias,
                              color: _3rdBox
                                  ? Colors.green[300]
                                  : Colors.amber[100],
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  'Check Affiliation',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                          TimelineTile(
                            alignment: TimelineAlign.center,
                            isFirst: false,
                            isLast: true,
                            indicatorStyle: IndicatorStyle(
                              width: 30,
                              color: _4thBox ? Colors.green : Colors.grey,
                              padding: const EdgeInsets.all(8),
                              iconStyle: IconStyle(
                                color: Colors.white,
                                iconData: Icons.check,
                              ),
                            ),
                            beforeLineStyle: LineStyle(
                              color: _4thBox ? Colors.green : Colors.grey,
                              thickness: 3,
                            ),
                            endChild: Card(
                              margin: EdgeInsets.symmetric(vertical: 26.0),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0)),
                              clipBehavior: Clip.antiAlias,
                              color: _4thBox
                                  ? Colors.green[300]
                                  : Colors.amber[100],
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  'Adding Affiliations..!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            ///med filessss builder
          ],
        ),
      ),
    );
  }
}
