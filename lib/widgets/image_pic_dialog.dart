import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'image_picker_handler.dart';

// ignore: must_be_immutable
class ImagePickerDialog extends StatelessWidget {
  ImagePickerHandler _listener;
  AnimationController _controller;
  BuildContext context;

  ImagePickerDialog(this._listener, this._controller);

  Animation<double> _drawerContentsOpacity;
  Animation<Offset> _drawerDetailsPosition;

  void initState() {
    _handleCameraAndMic();
    _drawerContentsOpacity = new CurvedAnimation(
      parent: new ReverseAnimation(_controller),
      curve: Curves.fastOutSlowIn,
    );
    _drawerDetailsPosition = new Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(new CurvedAnimation(
      parent: _controller,
      curve: Curves.fastOutSlowIn,
    ));
  }

  void onCamera() async {
    if (await Permission.camera.request().isGranted) {
      _listener.openCamera();
    } else if (await Permission.camera.request().isDenied) {
      await Permission.camera.request();
      Get.snackbar('Camera Access Denied', 'Allow Camera permission to continue',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: Duration(seconds: 5),
          isDismissible: false,
          mainButton: TextButton(
              style: TextButton.styleFrom(backgroundColor: Colors.white),
              onPressed: () async {
                await openAppSettings();
              },
              child: Text('Allow')));
    } else {
      Get.snackbar('Camera Access Denied', 'Allow Camera permission to continue',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: Duration(seconds: 5),
          isDismissible: false,
          mainButton: TextButton(
              style: TextButton.styleFrom(backgroundColor: Colors.white),
              onPressed: () async {
                await openAppSettings();
              },
              child: Text('Allow')));
    }
  }

  void onGallery() async {
    var permission = Permission.photos;
    if (Platform.isAndroid) {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      print(androidInfo.version.release);
      print(int.parse(androidInfo.version.release) <= 12);
      if (int.parse(androidInfo.version.release) <= 12) {
        permission = Permission.storage;
      }
    }
    if (await permission.request().isGranted) {
      _listener.openGallery();
    } else if (await permission.request().isDenied) {
      await permission.request();
      Get.snackbar('Gallery Access Denied', 'Allow Photos/Storage permission to continue',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: Duration(seconds: 5),
          isDismissible: false,
          mainButton: TextButton(
              style: TextButton.styleFrom(backgroundColor: Colors.white),
              onPressed: () async {
                await openAppSettings();
              },
              child: Text('Allow')));
    } else {
      Get.snackbar('Gallery Access Denied', 'Allow Photos/Storage permission to continue',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: Duration(seconds: 5),
          isDismissible: false,
          mainButton: TextButton(
              style: TextButton.styleFrom(backgroundColor: Colors.white),
              onPressed: () async {
                await openAppSettings();
              },
              child: Text('Allow')));
    }
  }

  Future<void> _handleCameraAndMic() async {
    var permission = Permission.photos;
    if (Platform.isAndroid) {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      print(androidInfo.version.release);
      print(int.parse(androidInfo.version.release) <= 12);
      if (int.parse(androidInfo.version.release) <= 12) {
        permission = Permission.storage;
      }
    }
    var result = await [Permission.camera, permission].request();
    if (await Permission.camera.request().isGranted) {
      if (await permission.request().isGranted) {
      } else if (await permission.request().isDenied) {
        await permission.shouldShowRequestRationale;
      } else {
        Get.snackbar('Gallery Access Denied', 'Allow Storage permission to continue',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: Duration(seconds: 5),
            isDismissible: false,
            mainButton: TextButton(
                style: TextButton.styleFrom(backgroundColor: Colors.white),
                onPressed: () async {
                  await openAppSettings();
                },
                child: Text('Allow')));
      }
    } else if (await Permission.camera.request().isDenied) {
      await Permission.camera.shouldShowRequestRationale;
    } else {
      Get.snackbar('Camera Access Denied', 'Allow Camera permission to continue',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: Duration(seconds: 5),
          isDismissible: false,
          mainButton: TextButton(
              style: TextButton.styleFrom(backgroundColor: Colors.white),
              onPressed: () async {
                await openAppSettings();
              },
              child: Text('Allow')));
    }
  }

  getImage(BuildContext context) {
    if (_controller == null || _drawerDetailsPosition == null || _drawerContentsOpacity == null) {
      return;
    }
    _controller.forward();
    showDialog(
      context: context,
      builder: (BuildContext context) => new SlideTransition(
        position: _drawerDetailsPosition,
        child: new FadeTransition(
          opacity: new ReverseAnimation(_drawerContentsOpacity),
          child: this,
        ),
      ),
    );
  }

  void dispose() {
    _controller.dispose();
  }

  startTime() async {
    var _duration = new Duration(milliseconds: 200);
    return new Timer(_duration, navigationPage);
  }

  void navigationPage() {
    Navigator.pop(context);
  }

  dismissDialog() {
    _controller.reverse();
    startTime();
  }

  @override
  Widget build(BuildContext context) {
    this.context = context;
    return new Material(
        type: MaterialType.transparency,
        child: new Opacity(
          opacity: 1.0,
          child: new Container(
            padding: EdgeInsets.fromLTRB(30.0, 0.0, 30.0, 20.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                new GestureDetector(
                  onTap: () => onCamera(),
                  child: roundedButton("Camera", EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
                      Color(0xFF19a9e5), const Color(0xFFFFFFFF)),
                ),
                new GestureDetector(
                  onTap: () => onGallery(),
                  child: roundedButton("Gallery", EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
                      Color(0xFF19a9e5), const Color(0xFFFFFFFF)),
                ),
                const SizedBox(height: 15.0),
                new GestureDetector(
                  onTap: () => dismissDialog(),
                  child: new Padding(
                    padding: EdgeInsets.fromLTRB(30.0, 0.0, 30.0, 0.0),
                    child: roundedButton("Cancel", EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
                        Colors.redAccent, const Color(0xFFFFFFFF)),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Widget roundedButton(String buttonLabel, EdgeInsets margin, Color bgColor, Color textColor) {
    var loginBtn = new Container(
      margin: margin,
      padding: EdgeInsets.all(15.0),
      alignment: FractionalOffset.center,
      decoration: new BoxDecoration(
        color: bgColor,
        borderRadius: new BorderRadius.all(const Radius.circular(100.0)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0xFF696969),
            offset: Offset(1.0, 6.0),
            blurRadius: 0.001,
          ),
        ],
      ),
      child: Text(
        buttonLabel,
        style: new TextStyle(color: textColor, fontSize: 20.0, fontWeight: FontWeight.bold),
      ),
    );
    return loginBtn;
  }
}
