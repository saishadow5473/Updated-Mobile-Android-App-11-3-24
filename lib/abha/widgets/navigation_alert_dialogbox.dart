import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class customDialogBox {
  navigationDialgo(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            // title: Text("Success"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    onTap: () {
                      Get.back();
                    },
                    child: Icon(
                      Icons.close,
                      color: Colors.blue.shade400,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                SizedBox(
                  width: Device.width,
                  child: InkWell(
                    onTap: () {
                      //Navigation
                    },
                    child: Card(
                      elevation: 4,
                      child: Align(
                          alignment: Alignment.center,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Login Using Aadhar",
                              style: TextStyle(
                                  color: Colors.black45,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.px),
                            ),
                          )),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                SizedBox(
                  width: Device.width,
                  child: InkWell(
                    onTap: () {
                      //Navigation
                    },
                    child: Card(
                      elevation: 4,
                      child: Align(
                          alignment: Alignment.center,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Login with Abha Account Password",
                              style: TextStyle(
                                  color: Colors.black45,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.px),
                            ),
                          )),
                    ),
                  ),
                )
              ],
            ),
          );
        });
  }
}
