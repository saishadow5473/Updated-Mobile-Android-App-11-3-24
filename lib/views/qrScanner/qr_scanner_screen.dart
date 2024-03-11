import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:ihl/new_design/presentation/pages/home/home_view.dart';
import 'package:ihl/new_design/presentation/pages/home/landingPage.dart';
import 'package:ihl/new_design/presentation/pages/profile/profile_screen.dart';
import 'package:ihl/utils/CrossbarUtil.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  Barcode result;
  QRViewController controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller.pauseCamera();
    }
    controller.resumeCamera();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WillPopScope(
        onWillPop: () {
          // Navigator.pushAndRemoveUntil(
          //     context,
          //     MaterialPageRoute(
          //         builder: (context) => HomeScreen(
          //               introDone: true,
          //             )),
          //     (Route<dynamic> route) => false);
          Get.back();
        },
        child: Scaffold(
          body: Container(
            child: Stack(
              children: <Widget>[
                _buildQrView(context),
                Positioned(
                  top: 20,
                  left: 20,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back_ios),
                    onPressed: () {
                      //  Navigator.pushAndRemoveUntil(
                      //   context,
                      //   MaterialPageRoute(builder: (context) => HomeScreen(introDone: true)),
                      //   (Route<dynamic> route) => false);
                      Get.back();
                    },
                    color: Colors.white,
                    tooltip: 'Back',
                  ),
                ),
                Positioned(
                  bottom: 50,
                  right: 100,
                  child: FutureBuilder(
                    future: controller?.getCameraInfo(),
                    builder: (context, snapshot) {
                      if (snapshot.data != null) {
                        var val = describeEnum(snapshot.data);
                        return IconButton(
                          icon: Icon(
                            Icons.change_circle_rounded,
                            color: Colors.white,
                            size: 70,
                          ),
                          onPressed: () async {
                            await controller?.flipCamera();
                            setState(() {});
                          },
                        );
                      } else {
                        return IconButton(
                          icon: Icon(
                            Icons.change_circle_rounded,
                            color: Colors.white,
                            size: 70,
                          ),
                          onPressed: () async {
                            await controller?.flipCamera();
                            setState(() {});
                          },
                        );
                      }
                    },
                  ),
                ),
                Positioned(
                    bottom: 40,
                    left: 100,
                    child: FutureBuilder(
                      future: controller?.getFlashStatus(),
                      builder: (context, snapshot) {
                        if (snapshot.data != null) {
                          var val = snapshot.data;
                          return val == true
                              ? IconButton(
                                  icon: Icon(
                                    Icons.flash_on_sharp,
                                    color: Colors.white,
                                    size: 50,
                                  ),
                                  onPressed: () async {
                                    await controller?.toggleFlash();
                                    setState(() {});
                                  },
                                )
                              : IconButton(
                                  icon: Icon(
                                    Icons.flash_off_sharp,
                                    color: Colors.white,
                                    size: 50,
                                  ),
                                  onPressed: () async {
                                    await controller?.toggleFlash();
                                    setState(() {});
                                  },
                                );
                        } else {
                          return IconButton(
                            icon: Icon(
                              Icons.flash_off_sharp,
                              color: Colors.white,
                              size: 50,
                            ),
                            onPressed: () async {
                              await controller?.toggleFlash();
                              setState(() {});
                            },
                          );
                        }
                      },
                    )),
                // Positioned(
                //     bottom: 40,
                //     right: 170,
                //     child: FutureBuilder(
                //       future: controller?.pauseCamera(),
                //       builder: (context, snapshot) {
                //         if (snapshot.data != null) {
                //           var val = snapshot.data;
                //           return val == false
                //               ? IconButton(
                //             icon: Icon(
                //               FontAwesomeIcons.play,
                //               color: Colors.white,
                //               size: 50,
                //             ),
                //             onPressed: () async {
                //               await controller?.resumeCamera();
                //               setState(() {});
                //             },
                //           )
                //               : IconButton(
                //             icon: Icon(
                //               Icons.pause,
                //               color: Colors.white,
                //               size: 50,
                //             ),
                //             onPressed: () async {
                //               await controller?.resumeCamera();
                //               setState(() {});
                //             },
                //           );
                //         } else {
                //           return IconButton(
                //             icon: Icon(
                //               FontAwesomeIcons.play,
                //               color: Colors.white,
                //               size: 50,
                //             ),
                //             onPressed: () async {
                //               await controller?.resumeCamera();
                //               setState(() {});
                //             },
                //           );
                //         }
                //       },
                //     )),
                // Expanded(
                //   flex: 1,
                //   child: FittedBox(
                //     fit: BoxFit.contain,
                //     child: Column(
                //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                //       children: <Widget>[
                //         if (result != null)
                //           Text(
                //               'Barcode Type: ${describeEnum(result.format)}   Data: ${result.code}')
                //         else
                //           const Text('Scan a code'),
                //         Row(
                //           mainAxisAlignment: MainAxisAlignment.center,
                //           crossAxisAlignment: CrossAxisAlignment.center,
                //           children: <Widget>[
                //             Container(
                //               margin: const EdgeInsets.all(8),
                //               child: ElevatedButton(
                //                   onPressed: () async {
                //                     await controller?.toggleFlash();
                //                     setState(() {});
                //                   },
                //                   child: FutureBuilder(
                //                     future: controller?.getFlashStatus(),
                //                     builder: (context, snapshot) {
                //                       return Text('Flash: ${snapshot.data}');
                //                     },
                //                   )),
                //             ),
                //             Container(
                //               margin: const EdgeInsets.all(8),
                //               child: ElevatedButton(
                //                   onPressed: () async {
                //                     await controller?.flipCamera();
                //                     setState(() {});
                //                   },
                //                   child: FutureBuilder(
                //                     future: controller?.getCameraInfo(),
                //                     builder: (context, snapshot) {
                //                       if (snapshot.data != null) {
                //                         return Text(
                //                             'Camera facing ${describeEnum(snapshot.data)}');
                //                       } else {
                //                         return const Text('loading');
                //                       }
                //                     },
                //                   )),
                //             )
                //           ],
                //         ),
                //         Row(
                //           mainAxisAlignment: MainAxisAlignment.center,
                //           crossAxisAlignment: CrossAxisAlignment.center,
                //           children: <Widget>[
                //             Container(
                //               margin: const EdgeInsets.all(8),
                //               child: ElevatedButton(
                //                 onPressed: () async {
                //                   await controller?.pauseCamera();
                //                 },
                //                 child: const Text('pause',
                //                     style: TextStyle(fontSize: 20)),
                //               ),
                //             ),
                //             Container(
                //               margin: const EdgeInsets.all(8),
                //               child: ElevatedButton(
                //                 onPressed: () async {
                //                   await controller?.resumeCamera();
                //                 },
                //                 child: const Text('resume',
                //                     style: TextStyle(fontSize: 20)),
                //               ),
                //             )
                //           ],
                //         ),
                //       ],
                //     ),
                //   ),
                // )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea =
        (MediaQuery.of(context).size.width < 400 || MediaQuery.of(context).size.height < 400)
            ? 200.0
            : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.red,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      if ((result == null && scanData.code != "this is just a demo code" && scanData.code != "") ||
          (scanData.code != "" &&
              scanData.code != "this is just a demo code" &&
              scanData.code != result.code)) {
        setState(() {
          result = scanData;
        });
        _sendData();
      }
    });
    this.controller.pauseCamera();
    this.controller.resumeCamera();
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    //log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
      // ScaffoldMessenger.of(context).hideCurrentSnackBar();
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _sendData() async {
    // show the loading dialog
    // Get.dialog(
    //     Dialog(
    //       // The background color
    //       backgroundColor: Colors.white,
    //       child: Padding(
    //         padding: const EdgeInsets.symmetric(vertical: 20),
    //         child: Column(
    //           mainAxisSize: MainAxisSize.min,
    //           children: const [
    //             // The loading indicator
    //             CircularProgressIndicator(),
    //             SizedBox(
    //               height: 15,
    //             ),
    //             // Some text
    //             Text('Trying to login...')
    //           ],
    //         ),
    //       ),
    //     ),
    //     barrierDismissible: false);
    // Your asynchronous computation here (fetching data from an API, processing files, inserting something to the database, etc)
    var resp = await kioskQrLoginCrossPublish(result.code);
    if (resp == "success") {
      Fluttertoast.showToast(
          msg: "success",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0);
      // Get.offAll(HomeScreen(introDone: true));
      Get.off(LandingPage());
    }
    if (resp == 'Failed') {
      Fluttertoast.showToast(
          msg: "Failed... Wrong Qr code",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.redAccent,
          textColor: Colors.white,
          fontSize: 16.0);
      Get.off(Profile());
      // setState(() {
      //   result = null;
      // });
    }
    // Close the dialog programmatically
    // Navigator.of(context).pop();
  }
}
