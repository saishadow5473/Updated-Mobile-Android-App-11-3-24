import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class CheckPermissions{
 static filePermissions(context) async {
    // await Permission.storage.request();
    // await Permission.mediaLibrary.request();
      // await Permission.activityRecognition.request();
   bool permissionGrandted = false;
   if (Platform.isAndroid) {
     final deviceInfo = await DeviceInfoPlugin().androidInfo;
     Map<Permission, PermissionStatus> _status;
     if (deviceInfo.version.sdkInt <= 32) {
       _status = await [Permission.storage].request();
     } else {
       _status = await [Permission.photos, Permission.videos].request();
     }
     _status.forEach((permission, status) {
       if (status == PermissionStatus.granted) {
         permissionGrandted = true;
       }
     });
   } else {
     await Permission.mediaLibrary.status;
     permissionGrandted = true;
   }
  if (permissionGrandted) {
        ///here
        return true;
      } else if (!permissionGrandted) {
    if (Platform.isAndroid) {
      final deviceInfo = await DeviceInfoPlugin().androidInfo;
      Map<Permission, PermissionStatus> _status;
      if (deviceInfo.version.sdkInt <= 32) {
        _status = await [Permission.storage].request();
      } else {
        _status = await [Permission.photos, Permission.videos].request();
      }
      _status.forEach((permission, status) {
        if (status == PermissionStatus.granted) {
          permissionGrandted = true;
        }
      });
    } else {
      await Permission.mediaLibrary.status;
      permissionGrandted = true;
    }
        if (permissionGrandted) {
          ///here
          return true;
        } else {
          showDialog(
              context: context,
              builder: (BuildContext context) =>CupertinoAlertDialog(
                title: new Text("Storage Access Denied"),
                content: new Text("Allow Storage permission to continue"),
                actions: <Widget>[
                  CupertinoDialogAction(
                    isDefaultAction: true,
                    child: Text("Yes"),
                    onPressed: () async {
                      await openAppSettings();
                      Get.back();
                    },
                  ),
                  CupertinoDialogAction(
                    child: Text("No"),
                    onPressed: ()=>Get.back(),
                  )
                ],
              ))  ;
          return false;
        }
      } else {
        showDialog(
            context: context,
            builder: (BuildContext context) =>CupertinoAlertDialog(
              title: new Text("Activity Access Denied"),
              content: new Text("Allow Activity permission to continue"),
              actions: <Widget>[
                CupertinoDialogAction(
                  isDefaultAction: true,
                  child: Text("Yes"),
                  onPressed: () async {
                    await openAppSettings();
                    Get.back();
                  },
                ),
                CupertinoDialogAction(
                  child: Text("No"),
                  onPressed: ()=>Get.back(),
                )
              ],
            ))  ;

        return false;
        // Get.snackbar(
        //     'Activity Access Denied', 'Allow Activity permission to continue',
        //     backgroundColor: Colors.red,
        //     colorText: Colors.white,
        //     duration: Duration(seconds: 5),
        //     isDismissible: false,
        //     mainButton: TextButton(
        //         onPressed: () async {
        //           await openAppSettings();
        //         },
        //         child: Text('Allow')));
      }
    }

 static cameraPermissions(context) async {
   // await Permission.storage.request();
   // await Permission.mediaLibrary.request();
   // await Permission.activityRecognition.request();
   var status = await Permission.camera.status;
   if (status.isGranted) {
     ///here
     return true;
   } else if (status.isDenied) {
     await Permission.camera.request();
     status =  await Permission.camera.status;
     if (status.isGranted) {
       ///here
       return true;
     } else {
       showDialog(
           context: context,
           builder: (BuildContext context) =>CupertinoAlertDialog(
             title: new Text("Camera Access Denied"),
             content: new Text("Allow Camera permission to continue"),
             actions: <Widget>[
               CupertinoDialogAction(
                 isDefaultAction: true,
                 child: Text("Yes"),
                 onPressed: () async {
                   await openAppSettings();
                   Get.back();
                 },
               ),
               CupertinoDialogAction(
                 child: Text("No"),
                 onPressed: ()=>Get.back(),
               )
             ],
           ))  ;
       return false;
     }
   } else {
     showDialog(
         context: context,
         builder: (BuildContext context) =>CupertinoAlertDialog(
           title: new Text("Activity Access Denied"),
           content: new Text("Allow Activity permission to continue"),
           actions: <Widget>[
             CupertinoDialogAction(
               isDefaultAction: true,
               child: Text("Yes"),
               onPressed: () async {
                 await openAppSettings();
                 Get.back();
               },
             ),
             CupertinoDialogAction(
               child: Text("No"),
               onPressed: ()=>Get.back(),
             )
           ],
         ))  ;

     return false;
     // Get.snackbar(
     //     'Activity Access Denied', 'Allow Activity permission to continue',
     //     backgroundColor: Colors.red,
     //     colorText: Colors.white,
     //     duration: Duration(seconds: 5),
     //     isDismissible: false,
     //     mainButton: TextButton(
     //         onPressed: () async {
     //           await openAppSettings();
     //         },
     //         child: Text('Allow')));
   }
 }

}