import 'package:get/get.dart';
import 'package:ihl/new_design/presentation/pages/dashboard/common_screen_for_navigation.dart';
import 'package:ihl/utils/commonUi.dart';
import 'package:flutter/services.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:ihl/models/ecg_calculator.dart';
import 'package:ihl/widgets/vitalScreen/HorizontalECG.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class ECGforNewScreen extends StatefulWidget {
  ECGforNewScreen({Key key, @required this.ecgValue, @required this.statusCard}) : super(key: key);
  final Map ecgValue;
  final Widget statusCard;
  _ECGforNewScreenState createState() => _ECGforNewScreenState();
}

class _ECGforNewScreenState extends State<ECGforNewScreen> {
  Map map;
  String string;

  bool showing = false;

  Widget createFullScreen(Map map, String string) {
    if (!showing) {
      return Container();
    }
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: RotatedBox(
            quarterTurns: 1,
            child: SizedBox(
              height: MediaQuery.of(context).size.height / 2,
              child: Card(
                color: AppColors.bgColorTab,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Text(
                              string + ':',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: CardColors.titleColor),
                            ),
                            SizedBox(
                              width: 40,
                              child: TextButton(
                                child: Icon(Icons.fullscreen_exit),
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.all(0),
                                ),
                                onPressed: () {
                                  showing = false;
                                  if (this.mounted) {
                                    setState(() {});
                                  }
                                },
                              ),
                            ),
                          ],
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height / 4,
                        width: MediaQuery.of(context).size.height,
                        child: HorizontalECGGraph(
                          ecg: map[string],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Map routeData = widget.ecgValue;
    ECGCalc ecg = routeData['ecgGraphData'];
    Map values = ecg.getMap();
    return WillPopScope(
      onWillPop: () async {
        SystemChrome.setPreferredOrientations(
            [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);

        if (showing == true) {
          showing = false;
          if (this.mounted) {
            setState(() {});
          }
          return false;
        }
        return true;
      },
      child: Stack(
        children: [
          CommonScreenForNavigation(
            appBar: AppBar(
              elevation: 0,
              backgroundColor: AppColors.primaryColor,
              leading: IconButton(
                onPressed: () => Get.back(),
                icon: Icon(Icons.arrow_back_ios_new_rounded),
              ),
              title: Text("ECG - Graphs"),
              centerTitle: true,
            ),
            content: SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 3.h),
                    Padding(padding: EdgeInsets.all(8), child: widget.statusCard ?? Container()),
                    Padding(
                        padding: EdgeInsets.all(14),
                        child: Column(
                          children: values.keys.map((e) {
                            String key =
                                values.keys.where((element) => element == e).toList().first;
                            return Column(
                              children: <Widget>[
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(left: 10),
                                          child: Text(
                                            key.toString() + ':',
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.appTextColor),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 40,
                                          child: TextButton(
                                            child: Icon(Icons.fullscreen_rounded),
                                            style: TextButton.styleFrom(
                                              padding: EdgeInsets.all(0),
                                            ),
                                            onPressed: () {
                                              showing = true;
                                              string = key;
                                              map = values;
                                              if (this.mounted) {
                                                setState(() {});
                                              }
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: (MediaQuery.of(context).size.width) * 4 / 30,
                                      width: MediaQuery.of(context).size.width,
                                      child: HorizontalECGGraph(
                                        ecg: values[key],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 20.0,
                                ),
                              ],
                            );
                          }).toList(),
                        )),
                    SizedBox(height: 10.h),
                  ],
                ),
              ),
            ),
          ),
          createFullScreen(map, string)
        ],
      ),
    );
  }
}
