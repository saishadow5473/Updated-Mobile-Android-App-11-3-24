import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:connectanum/connectanum.dart';
import 'package:connectanum/json.dart';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:ihl/constants/api.dart';
import 'package:ihl/utils/CheckPermi.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/utils/screenutil.dart';
import 'package:ihl/views/teleconsultation/files/file_resuable_snackbar.dart';
import 'package:ihl/views/teleconsultation/files/pdf_viewer.dart';
import 'package:ihl/views/teleconsultation/viewallneeds.dart';
import 'package:ihl/widgets/BasicPageUI.dart';
import 'package:ihl/widgets/offline_widget.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:strings/strings.dart';

import '../../new_design/presentation/pages/onlineServices/MyAppointment.dart';

// import 'files/file_resuable_snackbar.dart';
//import 'files/pdf_viewer.dart';
/// Appointments 👀👀
class ShareDocumentFromMyAppointment extends StatefulWidget {
  ShareDocumentFromMyAppointment({this.ihlConsultantId, this.appointmentId});

  final appointmentId;
  final ihlConsultantId;

  @override
  _ShareDocumentFromMyAppointmentState createState() => _ShareDocumentFromMyAppointmentState();
}

class _ShareDocumentFromMyAppointmentState extends State<ShareDocumentFromMyAppointment> {
  http.Client _client = http.Client(); //3gb
  @override
  void initState() {
    // TODO: implement initState
    getDetails();
    super.initState();
  }

  List<String> sharedReportAppIdList = [];

  getDetails() async {
    SharedPreferences prefs1 = await SharedPreferences.getInstance();
    IHL_User_ID = prefs1.getString("ihlUserId");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    sharedReportAppIdList = prefs.getStringList('sharedReportAppIdList') ?? [];

    ///call the get medical files api
    medFiles = await MedicalFilesApi.getFiles();
    for (int i = 0; i < medFiles.length; i++) {
      var name;
      if (medFiles[i]['document_name'].toString().contains('.')) {
        var parse1 = medFiles[i]['document_name'].toString().replaceAll('.jpg', '');
        var parse2 = parse1.replaceAll('.jpeg', '');
        var parse3 = parse2.replaceAll('.png', '');
        var parse4 = parse3.replaceAll('.pdf', '');
        name = parse4;
      }
      filesNameList.add(name);
    }
    setState(() {
      medFiles;
    });
  }

  @override
  // final bool isHighlight;
  List medFiles = [];
  List filesNameList = [];
  var iHLUserId;
  var IHL_User_ID;
  List selectedDocIdList = [];
  Session session1, session;
  Client client;

  Widget build(BuildContext context) {
    return ConnectivityWidgetWrapper(
      disableInteraction: true,
      offlineWidget: OfflineWidget(),
      child: BasicPageUI(
          appBar: Column(
            children: [
              SizedBox(
                width: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BackButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      // if (isHighlight == false || isHighlight == null) {
                      //   Get.off(ViewallTeleDashboard());
                      // } else {
                      //   Get.off(ViewallTeleDashboard(
                      //     backNav: true,
                      //   ));
                      // }
                    },
                    color: Colors.white,
                  ),
                  Text(
                    'Share Medical Report',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: ScUtil().setSp(25),
                    ),
                  ),
                  SizedBox(
                    width: ScUtil().setWidth(40),
                  )
                ],
              ),
              SizedBox(
                height: ScUtil().setHeight(40),
              )
            ],
          ),
          body: Column(
            children: [
              filesCard(),
              SizedBox(
                height: 10,
              ),
              Center(
                child: SizedBox(
                    width: Get.width - 40,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        primary: AppColors.primaryColor,
                        textStyle: TextStyle(color: Colors.white),
                      ),
                      child: Text('Send Report',
                          style: TextStyle(
                            fontSize: 16,
                          )),
                      onPressed: () {
                        if (selectedDocIdList.length > 0) {
                          sendReports();
                        } else {
                          Get.snackbar(
                              'No Report Selected', 'Please Select at least 1 Report To Send',
                              icon: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(Icons.warning, color: Colors.white),
                              ),
                              margin: EdgeInsets.all(20).copyWith(bottom: 40),
                              backgroundColor: Colors.red.shade400,
                              colorText: Colors.white,
                              duration: Duration(seconds: 2),
                              snackPosition: SnackPosition.BOTTOM);
                        }
                      },
                    )),
              ),
            ],
          )),
      // WillPopScope(
      //   onWillPop: () => Get.off(ViewallTeleDashboard()),
      //   child: BasicPageUI(
      //     appBar: Column(
      //       children: [
      //         SizedBox(
      //           width: 20,
      //         ),
      //         Row(
      //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //           children: [
      //             BackButton(
      //               onPressed: () {
      //                 if (isHighlight == false || isHighlight == null) {
      //                   Get.off(ViewallTeleDashboard());
      //                 } else {
      //                   Get.off(ViewallTeleDashboard(
      //                     backNav: true,
      //                   ));
      //                 }
      //               },
      //               color: Colors.white,
      //             ),
      //             Text(
      //               AppTexts.myAppoitmentsTitle,
      //               style: TextStyle(color: Colors.white, fontSize: 25),
      //             ),
      //             SizedBox(
      //               width: 40,
      //             )
      //           ],
      //         ),
      //         SizedBox(
      //           height: 40,
      //         )
      //       ],
      //     ),
      //     body: UpcomingAppointments(),
      //   ),
      // ),
    );
  }

  Widget filesCard() {
    print('=============================$IHL_User_ID');
    iHLUserId = IHL_User_ID;
    print('=============================$iHLUserId');
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      color: FitnessAppTheme.white,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Select your files to share",
              style: TextStyle(
                color: AppColors.primaryAccentColor,
                fontSize: 22.0,
              ),
            ),
          ),
          Container(
            height: medFiles.length > 3
                ? 470
                : medFiles.length == 3
                    ? 290
                    : medFiles.length == 2
                        ? 190
                        : medFiles.length == 1
                            ? 100
                            : 10,
            child: ListView.builder(
              itemCount: medFiles.length,
              itemBuilder: (context, index) {
                return Column(
                  children: <Widget>[
                    ListTile(
                      leading: medFiles[index]['document_link'].substring(
                                      medFiles[index]['document_link'].lastIndexOf(".") + 1) ==
                                  'jpg' ||
                              medFiles[index]['document_link'].substring(
                                      medFiles[index]['document_link'].lastIndexOf(".") + 1) ==
                                  'png'
                          ? Icon(Icons.image)
                          : Icon(Icons.insert_drive_file),
                      // Icon(Icons.insert_drive_file),
                      title: Text("${medFiles[index]['document_name']}"),
                      subtitle: Text(
                          "${camelize(medFiles[index]['document_type'].replaceAll('_', ' '))}"),
                      // subtitle: Text("1.9 MB"),
                      trailing: checkboxTile(medFiles[index]['document_id']),
                      onTap: () async {
                        print(medFiles[index]['document_link']);
                        // if(filesData[index]['document_link'].contains('pdf')){
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PdfView(
                              medFiles[index]['document_link'],
                              medFiles[index],
                              iHLUserId,
                              showExtraButton: false,
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(
                      height: 5.0,
                    ),
                    Divider(
                      thickness: 2.0,
                      height: 10.0,
                      indent: 5.0,
                    ),
                  ],
                );
              },
            ),
          ),
          Center(
              child: SizedBox(
                  width: 180.0,
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.upload_file),
                    label: Text('New File',
                        style: TextStyle(
                          fontSize: 16,
                        )),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      primary: AppColors.primaryColor,
                      textStyle: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      showFileTypePicker(context);
                    },
                  ))),
          SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }

  ///ch
  Widget checkboxTile(String docId) {
    print(selectedDocIdList.toString());
    return Checkbox(
      value: selectedDocIdList.contains(docId.toString())
          ? true
          : false, //if this is in the list than add it or remove it
      onChanged: (value) {
        ///first check in the list and than
        ///if that item is available in the list already than => remove it from the list ,
        ///if item is not there in the list than add it
        if (selectedDocIdList.contains(docId.toString())) {
          setState(() {
            selectedDocIdList.remove(docId.toString());
          });
        } else {
          setState(() {
            selectedDocIdList.add(docId.toString());
          });
        }
        print('$selectedDocIdList');
      },
    );
  }

  sendReports() async {
    print(widget.ihlConsultantId);
    var aaaaa = jsonEncode({
      'ihl_user_id': "$iHLUserId",
      "document_id": selectedDocIdList,
      "appointment_id": widget.appointmentId, //"0b59bf916752496f98c53f94b0e50212",//appointmentId
      "ihl_consultant_id":
          widget.ihlConsultantId //"38726ba5bfcd42f08189e5e84a4105ca"//consultant_id
    });
    print(aaaaa);
    var cc = jsonEncode({
      'Content-Type': 'application/json',
      'ApiToken': '${API.headerr['ApiToken']}',
      'Token': '${API.headerr['Token']}',
    });
    print(cc);
    // assert(widget.ihlConsultantId!=null);
    final response = await _client.post(
      Uri.parse(API.iHLUrl + "/consult/share_medical_doc_after_appointment"),
      headers: {
        'Content-Type': 'application/json',
        'ApiToken': '${API.headerr['ApiToken']}',
        'Token': '${API.headerr['Token']}',
      },
      body: jsonEncode({
        'ihl_user_id': "$iHLUserId",
        "document_id": selectedDocIdList,
        "appointment_id": widget.appointmentId, //"0b59bf916752496f98c53f94b0e50212",//appointmentId
        "ihl_consultant_id":
            widget.ihlConsultantId //"38726ba5bfcd42f08189e5e84a4105ca"//consultant_id
      }),
    );
    print('${response.statusCode}');
    if (response.statusCode == 200) {
      var output = json.decode(response.body);
      //getFiles();//for  updating the listview again
      print(response.body);
      if (output['status'] == 'document uploaded successfully') {
        //snackbar
        // Get.snackbar('Deleted!', '${camelize(filename)} deleted successfully.',
        sharedReportAppIdList.add(widget.appointmentId);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setStringList('sharedReportAppIdList', sharedReportAppIdList);

        sharedFileCrossBarPublish();

        Get.snackbar('Report ', 'Sent Successfully',
            icon: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(Icons.check_circle, color: Colors.white)),
            margin: EdgeInsets.all(20).copyWith(bottom: 40),
            backgroundColor: AppColors.primaryAccentColor,
            colorText: Colors.white,
            duration: Duration(seconds: 5),
            snackPosition: SnackPosition.BOTTOM);

        // Timer(Duration(seconds: 2), () => Get.back());
        Get.off(MyAppointment(
          backNav: false,
        ));
        // Timer(duration:Duration(seconds: 1), (){
        //   Get.off(ViewallTeleDashboard());
        // });
        // getFiles();
      } else {
        Get.snackbar('Report Not Sent', 'Encountered some error while deleting. Please try again',
            icon: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(Icons.cancel_rounded, color: Colors.white),
            ),
            margin: EdgeInsets.all(20).copyWith(bottom: 40),
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: Duration(seconds: 5),
            snackPosition: SnackPosition.BOTTOM);
      }
    } else {
      print(response.body);
    }
  }

  /// upload medical files/reports
  var _chosenType = 'others';
  FilePickerResult result;
  bool fileSelected = false;
  PlatformFile file;
  TextEditingController fileNameController = TextEditingController();
  String fileNametext;

  showFileTypePicker(BuildContext context) {
    bool submitted = false;
    // ignore: missing_return
    String fileNameValidator(String ip) {
      if (ip == null) {
        return null;
      }
      if (ip.length < 1) {
        return 'File Name is required';
      }
      if (ip.length < 4) {
        return 'File Name should be at least 4 character long';
      }
      if (filesNameList.contains(ip)) {
        return 'File Name should be Unique';
      }
    }

    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.only(topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0)),
      ),
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter mystate) {
            return Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  fileSelected == false
                      ? Padding(
                          padding: const EdgeInsets.all(12.0).copyWith(left: 16),
                          child: AutoSizeText(
                            // 'Select File Type',
                            'Upload File',
                            style: TextStyle(
                                color: AppColors.appTextColor, //AppColors.primaryColor
                                fontSize: 22,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.left,
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(12.0).copyWith(left: 16),
                          child: AutoSizeText(
                            '${fileNametext + "." + "${isImageSelectedFromCamera ? 'jpg' : file.extension.toLowerCase()}"}',
                            style: TextStyle(
                                color: AppColors.appTextColor, //AppColors.primaryColor
                                fontSize: 15,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.left,
                          ),
                        ),
                  Visibility(
                    visible: fileSelected == false,
                    child: Divider(
                      indent: 10,
                      endIndent: 10,
                      thickness: 2,
                    ),
                  ),
                  Visibility(
                    visible: fileSelected == false,
                    child: Padding(
                      padding:
                          const EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0, bottom: 10.0),
                      child: TextFormField(
                        controller: fileNameController,
                        // validator: (v){
                        //   fileNameValidator(fileNametext);
                        // },
                        onChanged: (value) {
                          if (this.mounted) {
                            setState(() {
                              fileNametext = value;
                            });
                          }
                        },
                        // maxLength: 150,
                        autocorrect: true,
                        // scrollController: Scrollable,
                        autofocus: true,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 18),
                          labelText: "Enter file name",
                          errorText: fileNameValidator(fileNametext),
                          fillColor: Colors.white24,
                          border: new OutlineInputBorder(
                              borderRadius: new BorderRadius.circular(15.0),
                              borderSide: new BorderSide(color: Colors.blueGrey)),
                        ),
                        maxLines: 1,
                        style: TextStyle(fontSize: 16.0),
                        textInputAction: TextInputAction.done,
                      ),
                    ),
                  ),
                  fileSelected == false
                      ? Padding(
                          padding: const EdgeInsets.all(10.0).copyWith(left: 24, right: 24),
                          child: Container(
                            child: DropdownButton<String>(
                              focusColor: Colors.white,
                              value: _chosenType,
                              isExpanded: true,
                              underline: Container(
                                height: 2.0,
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      // color: widget.mealtype!=null?HexColor(widget.mealtype.startColor):AppColors.primaryColor,
                                      width: 2.0,
                                    ),
                                  ),
                                ),
                              ),
                              style: TextStyle(color: Colors.white),
                              iconEnabledColor: Colors.black,
                              items: <String>[
                                'lab_report',
                                'x_ray',
                                'ct_scan',
                                'mri_scan',
                                'others'
                              ].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    camelize(value.replaceAll('_', ' ')),
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                    ),
                                  ),
                                );
                              }).toList(),
                              hint: Text(
                                "Select File Type",
                                style: TextStyle(
                                    color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                              onChanged: (String value) {
                                mystate(() {
                                  _chosenType = value;
                                });
                                // //open file picker
                                // if(fileNameValidator(fileNametext)==null){
                                //   Navigator.of(context).pop();
                                //   sheetForSelectingReport(context);
                                // }
                                // else{
                                //   fileNameValidator(fileNametext);
                                // }
                              },
                            ),
                          ),
                        )
                      : Row(
                          children: [
                            MaterialButton(
                              child: Text(
                                'Change',
                                style: TextStyle(
                                    color: AppColors.primaryColor, //AppColors.primaryColor
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold),
                              ),
                              onPressed: () {
                                //open file explorer again
                                sheetForSelectingReport(context);
                              },
                            ),
                            MaterialButton(
                              child: Text(
                                'Confirm',
                                style: TextStyle(
                                    color: AppColors.primaryColor, //AppColors.primaryColor
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold),
                              ),
                              onPressed: () {
                                //pop
                                Navigator.pop(context);
                                // Navigator.pop(context);
                                setState(() {
                                  fileSelected = false;
                                });

                                ///send this payload diffrently if file selected from camera
                                if (isImageSelectedFromCamera) {
                                  var n = croppedFile.path
                                      .substring(croppedFile.path.lastIndexOf('/') + 1);
                                  uploadDocuments(n, 'jpg', croppedFile.path);
                                } else {
                                  uploadDocuments(result.files.first.name,
                                      result.files.first.extension, result.files.first.path);
                                }

                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (ctx) => AlertDialog(
                                    title: Text("Uploading..."),
                                    content: Text("Please Wait. The File is Uploading..."),
                                    actions: <Widget>[
                                      CircularProgressIndicator(),
                                      // FlatButton(
                                      //   onPressed: () {
                                      //     Navigator.of(ctx).pop();
                                      //   },
                                      //   child: Text("okay"),
                                      // ),
                                    ],
                                  ),
                                );

                                fileNameController.clear();
                              },
                            ),
                          ],
                        ),
                  Visibility(
                    visible: fileSelected == false,
                    child: Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          // primary: Colors.green.withOpacity(1),
                          // primary: AppColors.primaryColor,
                          primary: AppColors.primaryAccentColor,
                          textStyle:
                              TextStyle(fontSize: ScUtil().setSp(14), fontWeight: FontWeight.bold),
                        ),
                        onPressed: () async {
                          //open file picker
                          if (fileNameValidator(fileNametext) == null && fileNametext.length != 0) {
                            Navigator.of(context).pop();
                            sheetForSelectingReport(context);
                            // _openFileExplorer('upload');

                            // showDialog(
                            //   context: context,
                            //   builder: (ctx) => AlertDialog(
                            //     title: Text("Alert Dialog Box"),
                            //     content: Text("You have raised a Alert Dialog Box"),
                            //     actions: <Widget>[
                            //       FlatButton(
                            //         onPressed: () {
                            //           Navigator.of(ctx).pop();
                            //         },
                            //         child: Text("okay"),
                            //       ),
                            //     ],
                            //   ),
                            // );
                          } else {
                            fileNameValidator(fileNametext);
                            FocusManager.instance.primaryFocus?.unfocus();
                          }
                        },
                        child: Text(
                          ' Upload ',
                          style: TextStyle(
                              color: Colors.white,
                              letterSpacing: 1.5,
                              fontSize: ScUtil().setSp(16)),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: ScUtil().setHeight(60)),
                ],
              ),
            );
          },
        );
      },
    );
  }

  sheetForSelectingReport(BuildContext context) {
    // ignore: missing_return
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.only(topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0)),
      ),
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter mystate) {
            return Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // fileSelected == false
                  //     ? Padding(
                  //   padding: const EdgeInsets.all(12.0).copyWith(left: 16),
                  //   child: AutoSizeText(
                  //     // 'Select File Type',
                  //     'Upload File',
                  //     style: TextStyle(
                  //         color: AppColors.appTextColor, //AppColors.primaryColor
                  //         fontSize: 22,
                  //         fontWeight: FontWeight.bold),
                  //     textAlign: TextAlign.left,
                  //   ),
                  // )
                  //     : Padding(
                  //   padding: const EdgeInsets.all(12.0).copyWith(left: 16),
                  //   child: AutoSizeText(
                  //     '${fileNametext+'.'+file.extension.toLowerCase()}',
                  //     style: TextStyle(
                  //         color: AppColors.appTextColor, //AppColors.primaryColor
                  //         fontSize: 15,
                  //         fontWeight: FontWeight.bold),
                  //     textAlign: TextAlign.left,
                  //   ),
                  // ),
                  //
                  // Visibility(
                  //   visible: fileSelected == false,
                  //   child: Divider(
                  //     indent: 10,
                  //     endIndent: 10,
                  //     thickness: 2,
                  //   ),
                  // ),
                  ListTile(
                    title: Text('Select Report From Storage'),
                    leading: Icon(Icons.image),
                    onTap: () async {
                      var status = await CheckPermissions.filePermissions(context);
                      if (status) {
                        _openFileExplorer('upload');
                      }
                    },
                  ),
                  ListTile(
                    title: Text('Capture Report From Camera'),
                    leading: Icon(Icons.camera_alt_outlined),
                    onTap: () async {
                      var status = await CheckPermissions.cameraPermissions(context);
                      if (status) {
                        await _imgFromCamera();
                        Navigator.of(context).pop();
                        showFileTypePicker(context);
                        setState(
                          () {
                            fileSelected = true;
                          },
                        );
                      }
                    },
                  ),
                  SizedBox(
                    height: ScUtil().setHeight(30),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  ///capture report from camera
  bool isImageSelectedFromCamera = false;

  File croppedFile;
  File _image;
  final picker = ImagePicker();

  _imgFromCamera() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);
    _image = new File(pickedFile.path);
    await ImageCropper().cropImage(
        sourcePath: _image.path,
        aspectRatio: CropAspectRatio(ratioX: 12, ratioY: 16),
        maxWidth: 512,
        maxHeight: 512,
        compressFormat: ImageCompressFormat.png,
        compressQuality: 60,
        uiSettings: [
          AndroidUiSettings(
            lockAspectRatio: false,
            activeControlsWidgetColor: AppColors.primaryAccentColor,
            toolbarTitle: 'Crop the Image',
            toolbarColor: Color(0xFF19a9e5),
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
          ),
          IOSUiSettings(title: 'Crop the Image', aspectRatioLockEnabled: true)
        ]).then((value) => croppedFile = File(value.path));

    if (this.mounted) {
      setState(() {
        List<int> imageBytes = croppedFile.readAsBytesSync();
        var im = croppedFile.path;
        isImageSelectedFromCamera = true;

        ///instead of image selected write here the older variable file selected = true, okay and than remove this file
        fileSelected = true;
      });
    }
  }

  ///file explorer
  Future<void> _openFileExplorer(type, {edit_doc_id, edit_doc_type}) async {
    result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'pdf'],
    );
    // FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      file = result.files.first;
      print(file.name);
      print(file.bytes);
      print(file.size);
      print(file.extension);
      print(file.path);
      setState(() {
        fileSelected = true;
        isImageSelectedFromCamera = false;
      });

      // if(type=='upload'){
      Navigator.pop(context);
      showFileTypePicker(context);
      // }

      // else{
      //   editDocuments(edit_doc_id,edit_doc_type);
      //
      // }
    } else {
      // User canceled the picker
    }
  }

  ///upload api
  Future uploadDocuments(String filename, String extension, String path) async {
    print('uploadDocuments apicalll');
    var request = http.MultipartRequest(
      'POST',
      Uri.parse(
          // 'https://testserver.indiahealthlink.com/consult/upload_medical_document'),
          API.iHLUrl + '/consult/upload_medical_document'),
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
      "document_name": "${fileNametext + '.' + extension.toLowerCase()}",
      "document_format_type": extension.toLowerCase() == 'pdf'
          ? "${extension.toLowerCase()}"
          : 'image', //"${extension.toLowerCase()}",
      "document_type": "$_chosenType",
    });
    var res = await request.send();
    print('success api ++');
    var uploadResponse = await res.stream.bytesToString();
    print(uploadResponse);
    final finalOutput = json.decode(uploadResponse);
    print(finalOutput['status']);
    if (finalOutput['status'] == 'document uploaded successfully') {
      Navigator.of(context).pop();
      //snackbar
      Get.snackbar('Uploaded!',
          '${camelize(fileNametext + '.' + extension.toLowerCase())} uploaded successfully.',
          icon: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(Icons.check_circle, color: Colors.white)),
          margin: EdgeInsets.all(20).copyWith(bottom: 40),
          backgroundColor: AppColors.primaryAccentColor,
          colorText: Colors.white,
          duration: Duration(seconds: 5),
          snackPosition: SnackPosition.BOTTOM);
      medFiles = await MedicalFilesApi.getFiles();
      for (int i = 0; i < medFiles.length; i++) {
        var name;
        if (medFiles[i]['document_name'].toString().contains('.')) {
          var parse1 = medFiles[i]['document_name'].toString().replaceAll('.jpg', '');
          var parse2 = parse1.replaceAll('.jpeg', '');
          var parse3 = parse2.replaceAll('.png', '');
          var parse4 = parse3.replaceAll('.pdf', '');
          name = parse4;
        }
        filesNameList.add(name);
      }

      ///added\\improvised for the confirm visit
      setState(() {
        medFiles;
      });
      // getFiles();
    } else {
      Get.snackbar('File not uploaded', 'Encountered some error while uploading. Please try again',
          icon: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(Icons.cancel_rounded, color: Colors.white)),
          margin: EdgeInsets.all(20).copyWith(bottom: 40),
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: Duration(seconds: 5),
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  void connect() async {
    client = Client(
        realm: 'crossbardemo',
        transport: WebSocketTransport(
          API.crossbarUrl,
          Serializer(),
          WebSocketSerialization.SERIALIZATION_JSON,
        ));
  }

  void sharedFileCrossBarPublish() async {
    connect();
    session1 = await client.connect().first;

    SharedPreferences prefs = await SharedPreferences.getInstance();

    // var data = prefs.get('data');
    // Map res = jsonDecode(data);
    // iHLUserId = res['User']['id'];
    var q = {
      'data': {
        'ihl_user_id': "$iHLUserId",
        "document_id": selectedDocIdList, //selectDocumentIdList
        "appointment_id": widget.appointmentId
            .toString()
            .replaceAll('ihl_consultant_', ''), //"0b59bf916752496f98c53f94b0e50212",//appointmentId
        "ihl_consultant_id":
            widget.ihlConsultantId, //"38726ba5bfcd42f08189e5e84a4105ca"//consultant_id
      }
    };

    try {
      await session1.publish('medical_report_share',
          arguments: [q], options: PublishOptions(retain: false));
    } on Abort catch (abort) {
      print(abort.message.message);
    }
  }
}
