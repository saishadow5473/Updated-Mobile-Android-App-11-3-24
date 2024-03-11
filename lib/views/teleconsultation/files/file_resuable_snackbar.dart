import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:ihl/constants/api.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:strings/strings.dart';

/// in the error snack bar the function only expecting edit/upload/download not edited...okay!!!
snackBarForError({String snackName, String fileName}) {
  Get.snackbar('File not ${camelize(snackName)}ed',
      'Encountered some error while ${snackName.toLowerCase()}ing. Please try again',
      icon: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(Icons.cancel_rounded, color: Colors.white)),
      margin: EdgeInsets.all(20).copyWith(bottom: 40),
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: Duration(seconds: 5),
      snackPosition: SnackPosition.BOTTOM);
}

snackBarForSuccess({String snackName, String fileName}) {
  Get.snackbar(
      '${camelize(snackName)}!', '${camelize(fileName)} ${snackName.toLowerCase()} successfully.',
      icon: Padding(
          padding: const EdgeInsets.all(8.0), child: Icon(Icons.check_circle, color: Colors.white)),
      margin: EdgeInsets.all(20).copyWith(bottom: 40),
      backgroundColor: AppColors.primaryAccentColor,
      colorText: Colors.white,
      duration: Duration(seconds: 5),
      snackPosition: SnackPosition.BOTTOM);
}

///edit api
class MedicalFilesApi {
  static editDocumentsApi({filename, iHLUserId, extension, doctype, docmentId, path}) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse(API.iHLUrl + '/consult/edit_medical_document'),
    );
    request.headers.addAll(
      {
        'Content-Type': 'application/json',
        'ApiToken': '${API.headerr['ApiToken']}',
        'Token': '${API.headerr['Token']}',
      },
    );
    request.files.add(
      await http.MultipartFile.fromPath(
        'data',
        path,
        filename: filename,
      ),
    );
    request.fields.addAll(await {
      "ihl_user_id": "$iHLUserId",
      "document_name": "$filename",
      "document_format_type": extension.toLowerCase() == 'pdf'
          ? "${extension.toLowerCase()}"
          : 'image', //"${extension.toLowerCase()}",
      "document_type": "$doctype",
      "document_id": "$docmentId"
    });
    var res = await request.send();
    var editResponse = await res.stream.bytesToString();
    final finalOutput = json.decode(editResponse);
    return finalOutput;
  }

//delete api
  static deleteFileApi(String documentId, String filename, iHLUserId) async {
    http.Client _client = http.Client(); //3gb
    final response = await _client.post(
      Uri.parse(API.iHLUrl + "/consult/delete_medical_document"),
      headers: {
        'Content-Type': 'application/json',
        'ApiToken': '${API.headerr['ApiToken']}',
        'Token': '${API.headerr['Token']}',
      },
      body: jsonEncode({
        'ihl_user_id': "$iHLUserId",
        "document_id": [documentId]
      }),
    );
    print('${response.statusCode}');
    if (response.statusCode == 200) {
      var output = json.decode(response.body);
      //getFiles();//for  updating the listview again
      print(response.body);
      return output;
    } else {
      print(response.body);
    }
  }

  static getFiles({ihlID}) async {
    http.Client _client = http.Client(); //3gb
    // idAvailable=idAvailable??false;
    // if(!idAvailable){
    SharedPreferences prefs1 = await SharedPreferences.getInstance();
    var data1 = prefs1.get('data');
    Map res = jsonDecode(data1);
    var iHLUserId = res['User']['id'];
    // }
    final getUserFile = await _client.post(
      Uri.parse(API.iHLUrl + "/consult/view_user_medical_document"),
      headers: {
        'Content-Type': 'application/json',
        'ApiToken': '${API.headerr['ApiToken']}',
        'Token': '${API.headerr['Token']}',
      },
      body: jsonEncode(<String, String>{
        'ihl_user_id': "$iHLUserId", //"soTlvURs30uyrVP8osAZeQ",
      }),
    );
    print('${getUserFile.statusCode}');
    if (getUserFile.statusCode == 200) {
      final filesData = json.decode(getUserFile.body);
      // setState(() {
      //   loading = false;
      //   filesData;
      // });

      print(getUserFile.body);
      return filesData;
    } else {
      print(getUserFile.body);
      // return 'error';
    }
  }

  static getFilesSummary(ihl_consultant_id, {appID}) async {
    http.Client _client = http.Client(); //3gb
    // idAvailable=idAvailable??false;
    // if(!idAvailable){
    // SharedPreferences prefs1 = await SharedPreferences.getInstance();
    // var data1 = prefs1.get('data');
    // Map res = jsonDecode(data1);
    // var iHLUserId = res['User']['id'];
    // }
    final getUserFile = await _client.post(
      Uri.parse(API.iHLUrl + "/consult/view_user_medical_document"),
      headers: {
        'Content-Type': 'application/json',
        'ApiToken': '${API.headerr['ApiToken']}',
        'Token': '${API.headerr['Token']}',
      },
      body: jsonEncode(<String, String>{
        'Appointment_id': "$appID", //"soTlvURs30uyrVP8osAZeQ",
      }),
    );
    print('${getUserFile.statusCode}');
    if (getUserFile.statusCode == 200) {
      var parse1 = getUserFile.body.replaceAll(ihl_consultant_id, '');
      final List filesData = json.decode(getUserFile.body);
      filesData.forEach((element) {
        element['document_name'] =
            element['document_name'].toString().replaceAll(ihl_consultant_id, '');
      });
      // setState(() {
      //   loading = false;
      //   filesData;
      // });
      print('===>' + filesData.toString());
      print(getUserFile.body);
      return filesData;
    } else {
      print(getUserFile.body);
      return [];
    }
  }

  ///download api

  static download(fileName, url) async {
    // String fileName = 'subsId' + "_" + 'appointmentOnPdfSave' + " " + 'time';

    // Directory internalDirectory;
    // String dir;
    // if (Platform.isAndroid) {
    //   List<Directory> downloadsDirectory =
    //       await getExternalStorageDirectories(type: StorageDirectory.documents);//docments
    //   if (downloadsDirectory == null && downloadsDirectory.isEmpty) {
    //     internalDirectory = await getApplicationDocumentsDirectory();
    //   }
    //   dir = downloadsDirectory[0].path ?? internalDirectory.path;
    // } else if (Platform.isIOS) {
    //   internalDirectory = await getApplicationDocumentsDirectory();
    //   dir = internalDirectory.path;
    // }
    // final String path = '$dir/' + fileName + ".pdf";
    // final File file = File(path);
    // await file.writeAsBytes(await pdf.save());
    // PdfView p = PdfView('');
    // p.createFileOfPdfUrl();
    // final taskId = await FlutterDownloader.enqueue(
    //   url: '$url',
    //   savedDir: '$dir',//'the path of directory where you want to save downloaded files',
    //   showNotification: true, // show download progress in status bar (for Android)
    //   openFileFromNotification: true, // click on notification to open downloaded file (for Android)
    // );
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

    final status = await permission.request();

    if (status.isGranted) {
      final externalDir = await getExternalStorageDirectories(type: StorageDirectory.documents);
      // await getExternalStorageDirectory();

      final id = await FlutterDownloader.enqueue(
        url: '$url',
        savedDir: externalDir[0].path,
        fileName: fileName,
        showNotification: true,
        openFileFromNotification: true,
      );
      //snack bar for
      snackBarForSuccess(snackName: 'download', fileName: 'Saved in the Download folder'
          // externalDir[0].path.toString()
          );
    } else {
      print("Permission deined");
    }

    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // prefs.setString("pdfPath", path);
  }

  static downloadImageForEdit(fileName, url) async {
    // String fileName = 'subsId' + "_" + 'appointmentOnPdfSave' + " " + 'time';

    // Directory internalDirectory;
    // String dir;
    // if (Platform.isAndroid) {
    //   List<Directory> downloadsDirectory =
    //       await getExternalStorageDirectories(type: StorageDirectory.documents);//docments
    //   if (downloadsDirectory == null && downloadsDirectory.isEmpty) {
    //     internalDirectory = await getApplicationDocumentsDirectory();
    //   }
    //   dir = downloadsDirectory[0].path ?? internalDirectory.path;
    // } else if (Platform.isIOS) {
    //   internalDirectory = await getApplicationDocumentsDirectory();
    //   dir = internalDirectory.path;
    // }
    // final String path = '$dir/' + fileName + ".pdf";
    // final File file = File(path);
    // await file.writeAsBytes(await pdf.save());
    // PdfView p = PdfView('');
    // p.createFileOfPdfUrl();
    // final taskId = await FlutterDownloader.enqueue(
    //   url: '$url',
    //   savedDir: '$dir',//'the path of directory where you want to save downloaded files',
    //   showNotification: true, // show download progress in status bar (for Android)
    //   openFileFromNotification: true, // click on notification to open downloaded file (for Android)
    // );
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
      permissionGrandted = true;
    }

    if (permissionGrandted) {
      // final externalDir =
      // // await getExternalStorageDirectories(type: StorageDirectory.documents);
      // (await getApplicationDocumentsDirectory()).path;
      // // await getExternalStorageDirectory();
      //
      //
      // final id = await FlutterDownloader.enqueue(
      //   url:'$url',
      //   savedDir: externalDir,//externalDir[0].path,
      //   fileName: fileName,
      //   showNotification: false,
      //   openFileFromNotification: false,
      // );
      // //snack bar for
      // // snackBarForSuccess(snackName: 'download',fileName:'Saved in the Download folder'
      //   // externalDir[0].path.toString()
      // // );
      // return externalDir+'$fileName';

      var request = await HttpClient().getUrl(Uri.parse(url));
      var response = await request.close();
      var bytes = await consolidateHttpClientResponseBytes(response);
      String dir = (await getApplicationDocumentsDirectory()).path;
      File existfile = new File('$dir/$fileName');
      await existfile.writeAsBytes(bytes);

      return existfile.path;
    } else {
      print("Permission deined");
    }

    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // prefs.setString("pdfPath", path);
  }
}
