import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ihl/utils/CrossbarUtil.dart';
import 'package:ihl/widgets/BasicPageUI.dart';
import 'package:lottie/lottie.dart';

import '../../new_design/presentation/pages/spalshScreen/splashScreen.dart';

class NoInternetPage extends StatefulWidget {
  @override
  _NoInternetPageState createState() => _NoInternetPageState();
}

class _NoInternetPageState extends State<NoInternetPage> {
  @override
  void initState() {
    // TODO: implement initState
    currentPage = "NoInternetPage";
    istimerForCAM = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var queryHeight = MediaQuery.of(context).size.height;
    var querywidth = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: null,
      child: WillPopScope(
        onWillPop: null,
        child: BasicPageUI(
          body: Column(
            children: [
              Container(
                width: querywidth / 1.05,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 40,
                    ),
                    Lottie.asset('assets/reconnecting.json',
                        height: queryHeight / 2, width: querywidth / 1.05),
                    Text(
                      "OOPS! \nNO INTERNET",
                      style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900),
                    ),
                    Text(
                      "Please check your network connection.",
                      style: TextStyle(color: Colors.grey),
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    SizedBox(
                      width: querywidth / 1.15,
                      child: ElevatedButton(
                        onPressed: () async {
                          bool result = await DataConnectionChecker().hasConnection;
                          if (result == true) {
                            Get.offAll(SplashScreen(
                                //isReload: true,
                                ));
                          } else {
                            Flushbar(
                              title: "Offline",
                              message: "No Internet",
                              duration: Duration(seconds: 3),
                            )..show(context);
                          }
                        },
                        child: Text(
                          "TRY AGAIN",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
