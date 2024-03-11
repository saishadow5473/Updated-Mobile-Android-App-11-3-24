import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Getx/controller/google_fit_controller.dart';
import '../../new_design/presentation/pages/home/landingPage.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class customPopup {
  startButton({BuildContext context, VoidCallback onTap, bool color, bool nrmlnavi}) {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return WillPopScope(
            onWillPop: () {
              if (nrmlnavi) {
                print('nrml');
                Get.back();
                Get.back();
              } else {
                Get.offAll(LandingPage(), transition: Transition.size);
              }
            },
            child: Material(
              color: Colors.grey.shade200.withOpacity(0.5),
              child: InkWell(
                onTap: color
                    ? () {}
                    : () {
                        final _listController = Get.find<HealthRepository>();
                        _listController.isLoading = false;
                        _listController.started = false;
                        _listController.steps = 0;
                        _listController.update();
                        Get.back();
                      },
                child: Stack(
                  children: [
                    Platform.isIOS
                        ? Align(
                            alignment: Alignment.topRight,
                            child: IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                if (nrmlnavi) {
                                  print('nrml');
                                  Get.back();
                                  Get.back();
                                } else {
                                  Get.offAll(LandingPage());
                                }
                              },
                            ),
                          )
                        : const SizedBox(),
                    Align(
                      alignment: Alignment.center,
                      child: GestureDetector(
                        onTap: onTap,
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            boxShadow: [
                              const BoxShadow(
                                  offset: Offset(1, 1),
                                  color: Colors.blueGrey,
                                  spreadRadius: 2,
                                  blurRadius: 2)
                            ],
                            border: Border.all(color: Colors.white, width: 2),
                            shape: BoxShape.circle,
                            color: color ? Colors.lightBlue : Colors.grey,
                          ),
                          height: Device.width / 2.3,
                          width: Device.width / 2.3,
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white, width: 1),
                              shape: BoxShape.circle,
                              color: color ? Colors.lightBlue : Colors.grey,
                            ),
                            height: Device.width / 2.7,
                            width: Device.width / 2.7,
                            child: Text(
                              "Begin\nChallenge",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 17.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.8),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
