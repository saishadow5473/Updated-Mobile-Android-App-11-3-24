import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_exif_rotation/flutter_exif_rotation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:ihl/constants/api.dart';
import 'package:ihl/new_design/presentation/pages/dashboard/common_screen_for_navigation.dart';
import 'package:ihl/utils/CheckPermi.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/views/teleconsultation/files/file_resuable_snackbar.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:strings/strings.dart';

import '../../../new_design/presentation/controllers/teleconsultation_onlineServices/teleconsultation_functions.dart';
import '../../../new_design/presentation/pages/onlineServices/medFileblocs/medFileBloc.dart';
import '../../../new_design/presentation/pages/onlineServices/medFileblocs/medFileEvent.dart';
import '../../../new_design/presentation/pages/onlineServices/medFileblocs/medFileState.dart';
import '../../../new_design/presentation/pages/onlineServices/myAppointmentsTabs.dart';

import 'pdf_viewer.dart';

class MedicalFiles extends StatefulWidget {
  String ihlConsultantId;
  String appointmentId;
  final category;
  bool medicalFiles, normalFlow, consultStages;

  MedicalFiles(
      {Key key,
      this.category,
      this.medicalFiles,
      this.ihlConsultantId,
      this.appointmentId,
      this.consultStages,
      this.normalFlow})
      : super(key: key);

  @override
  _MedicalFilesState createState() => _MedicalFilesState();
}

class _MedicalFilesState extends State<MedicalFiles> {
  http.Client _client = http.Client(); //3gb
  List<Map> fileTree = [];
  Map fileStructure = {};
  bool loading = true;
  List<String> selectedListNormal = [];

  // final ValueNotifier<List<String>> selectedDocIdList = ValueNotifier([]);
  ValueNotifier<bool> medicalFileShared = ValueNotifier(false);
  var filesreportFiles;

  getCurrentFolder() {}
  var _chosenType = 'Others';
  FilePickerResult result;
  bool fileSelected = false;
  PlatformFile file;
  TextEditingController fileNameController = TextEditingController();
  String fileNametext;

  /// fetch data ☑
  Future getData() async {
    String fileResponseRaw = await rootBundle.loadString('assets/files.json');
    Map teleConsulResponse = json.decode(fileResponseRaw);
    fileStructure = teleConsulResponse;
    fileTree.add(fileStructure);
    loading = false;
    if (this.mounted) {
      setState(() {});
    }
  }

  /// top file path 📂
  Widget getTopLabel() {
    return RichText(
      text: TextSpan(
        style: const TextStyle(color: Colors.black),
        children: fileTree.map((e) => TextSpan(text: e['name'].toString() + '/ ')).toList(),
      ),
    );
  }

  /// loading animation ⏰
  loadForMilliSeconds(int seconds) {
    if (this.mounted) {
      setState(() {
        loading = true;
      });
    }
    Future.delayed(Duration(milliseconds: seconds)).then((value) {
      if (this.mounted) {
        setState(() {
          loading = false;
        });
      }
    });
  }

  /// go to a folder 📂
  setCurrentFolder(Map map) {
    if (this.mounted) {
      setState(() {
        fileTree.add(map);
      });
    }
  }

  int progress = 0;

  ReceivePort _receivePort = ReceivePort();

  static downloadingCallback(id, status, progress) {
    ///Looking up for a send port
    SendPort sendPort = IsolateNameServer.lookupPortByName("downloading");

    ///ssending the data
    sendPort.send([id, status, progress]);
  }

  @override
  void initState() {
    super.initState();
    // 'lab_report',
    // 'x_ray',
    // 'ct_scan',
    // 'mri_scan',
    // 'others'
    fileNameController.clear();
    if (widget.category.toString().toLowerCase().contains('ther')) {
      _chosenType = 'others';
    } else if (widget.category.toString().toLowerCase().contains('lab')) {
      _chosenType = 'lab_report';
    } else if (widget.category.toString().toLowerCase().contains('mri')) {
      _chosenType = 'mri_scan';
    } else if (widget.category.toString().toLowerCase().contains('ct')) {
      _chosenType = 'ct_scan';
    } else if (widget.category.toString().toLowerCase().contains('x')) {
      _chosenType = 'x_ray';
    }

    ///register a send port for the other isolates
    IsolateNameServer.registerPortWithName(_receivePort.sendPort, "downloading");

    ///Listening for the data is comming other isolataes
    _receivePort.listen((message) {
      if (this.mounted) {
        setState(() {
          progress = message[2];
        });
      }

      print(progress);
    });

    FlutterDownloader.registerCallback(downloadingCallback);
    getFiles();
  }

  Widget FileOBJ(Map map, BuildContext cont) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const Icon(
          Icons.description,
          size: 100,
          color: AppColors.primaryAccentColor,
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const SizedBox(
                width: 40,
              ),
              Flexible(
                flex: 1,
                child: Text(
                  map['name'].toString(),
                  textAlign: TextAlign.center,
                ),
              ),
              GestureDetector(
                child: const Icon(Icons.more_vert),
                onTap: () {
                  showBottomSheet(
                    context: cont,
                    backgroundColor: Colors.black.withOpacity(0.3),
                    builder: (context) {
                      return GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height,
                          width: MediaQuery.of(context).size.width,
                          child: ListView(
                            reverse: true,
                            children: <Widget>[
                              Container(
                                color: AppColors.cardColor,
                                child: Column(
                                  children: <Widget>[
                                    ListTile(
                                      leading: const Icon(Icons.edit),
                                      title: const Text('Rename'),
                                      onTap: () {},
                                    ),
                                    const Divider(),
                                    ListTile(
                                      leading: const Icon(Icons.delete),
                                      title: const Text('Delete'),
                                      onTap: () {},
                                    ),
                                    const Divider(),
                                    ListTile(
                                      leading: const Icon(Icons.info),
                                      title: const Text('Details'),
                                      onTap: () {},
                                    ),
                                    const Divider(),
                                    ListTile(
                                      leading: const Icon(Icons.share),
                                      title: const Text('Share'),
                                      onTap: () {},
                                    ),
                                    const Divider(),
                                    ListTile(
                                      leading: const Icon(Icons.close),
                                      title: const Text('Cancel'),
                                      onTap: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget FolderOBJ(Map map, BuildContext cont) {
    return InkWell(
      onTap: () {
        loadForMilliSeconds(100);
        setCurrentFolder(map);
      },
      splashColor: AppColors.primaryAccentColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const Icon(
            Icons.folder,
            size: 100,
            color: AppColors.primaryAccentColor,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const SizedBox(
                  width: 40,
                ),
                Flexible(
                  flex: 1,
                  child: Text(
                    map['name'].toString(),
                    textAlign: TextAlign.center,
                  ),
                ),
                GestureDetector(
                  child: const Icon(Icons.more_vert),
                  onTap: () {
                    showBottomSheet(
                      context: cont,
                      backgroundColor: Colors.black.withOpacity(0.3),
                      builder: (context) {
                        return GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height,
                            width: MediaQuery.of(context).size.width,
                            child: ListView(
                              reverse: true,
                              children: <Widget>[
                                Container(
                                  color: AppColors.cardColor,
                                  child: Column(
                                    children: <Widget>[
                                      ListTile(
                                        leading: const Icon(Icons.edit),
                                        title: const Text('Rename'),
                                        onTap: () {},
                                      ),
                                      const Divider(),
                                      ListTile(
                                        leading: const Icon(Icons.delete),
                                        title: const Text('Delete'),
                                        onTap: () {},
                                      ),
                                      const Divider(),
                                      ListTile(
                                        leading: const Icon(Icons.info),
                                        title: const Text('Details'),
                                        onTap: () {},
                                      ),
                                      const Divider(),
                                      ListTile(
                                        leading: const Icon(Icons.share),
                                        title: const Text('Share'),
                                        onTap: () {},
                                      ),
                                      const Divider(),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// widget to show in grid
  List<Widget> currentDirectory(List list, BuildContext con) {
    return list.map((e) {
      if (e['type'] == 'folder') {
        return FolderOBJ(e, con);
      }
      return FileOBJ(e, con);
    }).toList();
  }

  var filesData = [];
  var allFiles;
  List filesNameList = [];
  var iHLUserId;

  getFiles({idAvailable}) async {
    idAvailable = idAvailable ?? false;
    if (!idAvailable) {
      SharedPreferences prefs1 = await SharedPreferences.getInstance();
      var data1 = prefs1.get('data');
      Map res = jsonDecode(data1);
      iHLUserId = res['User']['id'];
    }
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
      allFiles = json.decode(getUserFile.body);

      filesData = [];
      for (int i = 0; i < allFiles.length; i++) {
        var name;
        if (allFiles[i]['document_name'].toString().contains('.')) {
          var parse1 = allFiles[i]['document_name'].toString().replaceAll('.jpg', '');
          var parse2 = parse1.replaceAll('.jpeg', '');
          var parse3 = parse2.replaceAll('.png', '');
          var parse4 = parse3.replaceAll('.pdf', '');
          name = parse4;
        }
        filesNameList.add(name);
        if (((allFiles[i]['document_type'].replaceAll('_', ' ')).toString().toLowerCase()) ==
            (widget.category.toString().toLowerCase())) {
          // if(filesData.contains(allFiles[i]['document_name'])==false){
          filesData.add(allFiles[i]);
        }
      }

      if (mounted)
        setState(() {
          loading = false;
          filesData;
        });
      print(getUserFile.body);
    } else {
      print(getUserFile.body);
    }
  }

  @override
  Widget build(BuildContext context) {
    final MedFileBloc checkboxBloc = BlocProvider.of<MedFileBloc>(context);
    // Widget screen(Widget body) {
    //   return WillPopScope(
    //       onWillPop: () async {
    //         if (fileTree.length > 1) {
    //           fileTree.removeLast();
    //           loadForMilliSeconds(200);
    //           if (this.mounted) {
    //             setState(() {});
    //             return false;
    //           }
    //         }
    //         return true;
    //       },
    //       child: widget.medicalFiles && !widget.normalFlow
    //           ? SizedBox(
    //               height: 40.h,
    //             )
    //           : CommonScreenForNavigation(
    //               contentColor: '',
    //               appBar: AppBar(
    //                 backgroundColor: AppColors.primaryColor,
    //                 centerTitle: true,
    //                 leading: IconButton(
    //                   icon: Icon(Icons.arrow_back_ios),
    //                   onPressed: () {
    //                     Navigator.pop(context);
    //                   },
    //                   color: Colors.white,
    //                 ),
    //                 title: Text(
    //                   widget.category,
    //                   style: TextStyle(color: Colors.white, fontSize: 25),
    //                 ),
    //               ),
    //               content: filesData.length > 0
    //                   ? SingleChildScrollView(
    //                       child: Column(
    //                         children: [
    //                           SizedBox(
    //                             height: 74.h,
    //                             child: ListView.builder(
    //                                 itemCount: filesData.length,
    //                                 itemBuilder: (context, index) {
    //                                   return Padding(
    //                                     padding: const EdgeInsets.all(10.0),
    //                                     child: Card(
    //                                       elevation: 4,
    //                                       child: ListTile(
    //                                         leading: filesData[index]['document_link'].substring(
    //                                                         filesData[index]['document_link']
    //                                                                 .lastIndexOf(".") +
    //                                                             1) ==
    //                                                     'jpg' ||
    //                                                 filesData[index]['document_link'].substring(
    //                                                         filesData[index]['document_link']
    //                                                                 .lastIndexOf(".") +
    //                                                             1) ==
    //                                                     'png'
    //                                             ? Icon(Icons.image)
    //                                             : Icon(Icons.insert_drive_file),
    //                                         title: Text(filesData[index]['document_name']),
    //                                         subtitle: Text(
    //                                             "${camelize(filesData[index]['document_type'].replaceAll('_', ' '))}"),
    //                                         // trailing: checkboxTile(
    //                                         //     filesData[index]['document_id'], checkboxBloc),
    //                                         onTap: () async {
    //                                           print(filesData[index]['document_link']);
    //                                           // if(filesData[index]['document_link'].contains('pdf')){
    //                                           var returnData = await Navigator.push(
    //                                             context,
    //                                             MaterialPageRoute(
    //                                               builder: (context) => PdfView(
    //                                                 filesData[index]['document_link'],
    //                                                 filesData[index],
    //                                                 iHLUserId,
    //                                                 showExtraButton: true,
    //                                               ),
    //                                             ),
    //                                           );
    //                                           if (returnData ?? false) {
    //                                             //refresh the page
    //                                             getFiles(idAvailable: true);
    //                                           }
    //                                         },
    //                                       ),
    //                                     ),
    //                                   );
    //                                 }),
    //                           ),
    //                           ElevatedButton(
    //                               style: ElevatedButton.styleFrom(
    //                                 primary: AppColors.primaryColor,
    //                                 padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    //                               ),
    //                               onPressed: () {
    //                                 Get.to(InsideMedicalFiles(context));
    //                               },
    //                               child: Padding(
    //                                 padding: const EdgeInsets.all(12.0),
    //                                 child: Text('Upload'),
    //                               )),
    //                           SizedBox(
    //                             height: 5.h,
    //                           ),
    //                           widget.normalFlow
    //                               ? SizedBox()
    //                               : Center(
    //                                   child: SizedBox(
    //                                       width: 40.w,
    //                                       child: ElevatedButton(
    //                                         style: ElevatedButton.styleFrom(
    //                                           shape: RoundedRectangleBorder(
    //                                             borderRadius: BorderRadius.circular(4.0),
    //                                           ),
    //                                           primary: AppColors.primaryColor,
    //                                           textStyle: TextStyle(color: Colors.white),
    //                                         ),
    //                                         child: Text('SHARE FILE',
    //                                             style: TextStyle(
    //                                               fontSize: 16,
    //                                             )),
    //                                         onPressed: () {
    //                                           // if (bState.selectedDocIdList.isNotEmpty) {
    //                                           //   sendReports(
    //                                           //       ihlConsultationId: widget.ihlConsultantId,
    //                                           //       appointmentId: widget.appointmentId);
    //                                           // }
    //                                           // else {
    //                                           //   Get.snackbar('No Report Selected',
    //                                           //       'Please Select at least 1 Report To Send',
    //                                           //       icon: Padding(
    //                                           //         padding: const EdgeInsets.all(8.0),
    //                                           //         child:
    //                                           //         Icon(Icons.warning, color: Colors.white),
    //                                           //       ),
    //                                           //       margin: EdgeInsets.all(20).copyWith(bottom: 40),
    //                                           //       backgroundColor: Colors.red.shade400,
    //                                           //       colorText: Colors.white,
    //                                           //       duration: Duration(seconds: 2),
    //                                           //       snackPosition: SnackPosition.BOTTOM);
    //                                           // }
    //                                         },
    //                                       )),
    //                                 ),
    //                           SizedBox(
    //                             height: 15.h,
    //                           )
    //                         ],
    //                       ),
    //                     )
    //                   : Column(
    //                       crossAxisAlignment: CrossAxisAlignment.center,
    //                       mainAxisAlignment: MainAxisAlignment.center,
    //                       children: [
    //                         Center(
    //                           child: Text(
    //                             'No files have been uploaded.',
    //                             style: TextStyle(color: AppColors.primaryColor, fontSize: 20),
    //                             // subtitle: Text('               Click on the Button Below And\n               Add All Your Medical Files in one\n               Safe and Secure place.'),
    //                           ),
    //                         ),
    //                         SizedBox(
    //                           height: 5.h,
    //                         ),
    //                         ElevatedButton(
    //                             style: ElevatedButton.styleFrom(
    //                               primary: AppColors.primaryColor,
    //                               padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    //                             ),
    //                             onPressed: () {
    //                               Get.to(InsideMedicalFiles(context));
    //                             },
    //                             child: Padding(
    //                               padding: const EdgeInsets.all(12.0),
    //                               child: Text('Upload'),
    //                             ))
    //                       ],
    //                     ),
    //             ));
    // }
    bool isChecked = false;
    if (loading) {
      return widget.consultStages
          ? const Center(child: CircularProgressIndicator())
          : CommonScreenForNavigation(
              appBar: AppBar(
                backgroundColor: AppColors.primaryColor,
                centerTitle: true,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  color: Colors.white,
                ),
                title: Text(
                  widget.category,
                  style: const TextStyle(color: Colors.white, fontSize: 25),
                ),
              ),
              contentColor: '',
              content: const Center(child: CircularProgressIndicator()));
    }
    ScrollController sc = ScrollController();

    return widget.normalFlow
        ? BlocProvider(
            create: (BuildContext context) => MedFileBloc()..add(AddMedFileEvent()),
            child: BlocBuilder<MedFileBloc, MedFileState>(
                builder: (BuildContext ctx, MedFileState bState) {
              return CommonScreenForNavigation(
                  contentColor: '',
                  appBar: AppBar(
                    backgroundColor: AppColors.primaryColor,
                    centerTitle: true,
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back_ios),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      color: Colors.white,
                    ),
                    title: Text(
                      widget.category,
                      style: const TextStyle(color: Colors.white, fontSize: 25),
                    ),
                  ),
                  content: SingleChildScrollView(
                    child: filesData.length > 0
                        ? ScrollbarTheme(
                            data: ScrollbarThemeData(
                              thumbColor: MaterialStateProperty.all(
                                  AppColors.primaryAccentColor.withOpacity(0.4)),
                              interactive: true,
                              radius: const Radius.circular(10.0),
                              thickness: MaterialStateProperty.all(3),
                              minThumbLength: 60,
                            ),
                            child: Scrollbar(
                              thickness: 5,
                              thumbVisibility: true,
                              controller: sc,
                              child: Column(
                                children: <Widget>[
                                  SizedBox(
                                    height: 65.h,
                                    child: ListView.builder(
                                        controller: sc,
                                        itemCount: filesData.length,
                                        itemBuilder: (context, index) {
                                          return Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Card(
                                              elevation: 4,
                                              child: ListTile(
                                                leading: filesData[index]['document_link']
                                                                .substring(filesData[index]
                                                                            ['document_link']
                                                                        .lastIndexOf(".") +
                                                                    1) ==
                                                            'jpg' ||
                                                        filesData[index]['document_link'].substring(
                                                                filesData[index]['document_link']
                                                                        .lastIndexOf(".") +
                                                                    1) ==
                                                            'png'
                                                    ? const Icon(Icons.image)
                                                    : const Icon(Icons.insert_drive_file),
                                                title: Text(filesData[index]['document_name']),
                                                subtitle: Text(
                                                    "${camelize(filesData[index]['document_type'].replaceAll('_', ' '))}"),
                                                // trailing: checkboxTile(
                                                //     filesData[index]['document_id'], checkboxBloc),
                                                onTap: () async {
                                                  print(filesData[index]['document_link']);
                                                  // if(filesData[index]['document_link'].contains('pdf')){
                                                  var returnData = await Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => PdfView(
                                                        filesData[index]['document_link'],
                                                        filesData[index],
                                                        iHLUserId,
                                                        showExtraButton: true,
                                                      ),
                                                    ),
                                                  );
                                                  if (returnData ?? false) {
                                                    //refresh the page
                                                    getFiles(idAvailable: true);
                                                  }
                                                },
                                              ),
                                            ),
                                          );
                                        }),
                                  ),
                                  ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        primary: AppColors.primaryColor,
                                        padding:
                                            const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                                      ),
                                      onPressed: () {
                                        Get.to(InsideMedicalFiles(context));
                                      },
                                      child: const Padding(
                                        padding: EdgeInsets.all(12.0),
                                        child: Text('Upload'),
                                      )),
                                  SizedBox(
                                    height: 5.h,
                                  ),
                                  widget.normalFlow
                                      ? const SizedBox()
                                      : Center(
                                          child: SizedBox(
                                              width: 40.w,
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(4.0),
                                                  ),
                                                  primary: AppColors.primaryColor,
                                                  textStyle: const TextStyle(color: Colors.white),
                                                ),
                                                child: const Text('SHARE FILE',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                    )),
                                                onPressed: () {
                                                  if (bState.selectedDocIdList.isNotEmpty) {
                                                    sendReports(
                                                        ihlConsultationId: widget.ihlConsultantId,
                                                        appointmentId: widget.appointmentId);
                                                  } else {
                                                    Get.snackbar('No Report Selected',
                                                        'Please Select at least 1 Report To Send',
                                                        icon: const Padding(
                                                          padding: EdgeInsets.all(8.0),
                                                          child: Icon(Icons.warning,
                                                              color: Colors.white),
                                                        ),
                                                        margin: const EdgeInsets.all(20)
                                                            .copyWith(bottom: 40),
                                                        backgroundColor: Colors.red.shade400,
                                                        colorText: Colors.white,
                                                        duration: const Duration(seconds: 2),
                                                        snackPosition: SnackPosition.BOTTOM);
                                                  }
                                                },
                                              )),
                                        ),
                                  SizedBox(
                                    height: 15.h,
                                  )
                                ],
                              ),
                            ),
                          )
                        : SizedBox(
                            height: 88.h,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                const Center(
                                  child: Text(
                                    'No files have been uploaded.',
                                    style: TextStyle(color: AppColors.primaryColor, fontSize: 20),
                                    // subtitle: Text('               Click on the Button Below And\n               Add All Your Medical Files in one\n               Safe and Secure place.'),
                                  ),
                                ),
                                SizedBox(
                                  height: 5.h,
                                ),
                                ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      primary: AppColors.primaryColor,
                                      padding:
                                          const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                                    ),
                                    onPressed: () {
                                      Get.to(InsideMedicalFiles(context));
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.all(12.0),
                                      child: Text('Upload'),
                                    ))
                              ],
                            ),
                          ),
                  ));
            }))
        : BlocProvider<MedFileBloc>(
            create: (BuildContext context) => MedFileBloc()..add(AddMedFileEvent()),
            child: BlocBuilder<MedFileBloc, MedFileState>(
                builder: (BuildContext ctx, MedFileState bState) {
              return widget.consultStages
                  ? filesData.isNotEmpty
                      ? Column(
                          children: <Widget>[
                            SizedBox(
                              height: 39.h,
                              child: ListView.builder(
                                  itemCount: filesData.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    return Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Card(
                                        elevation: 4,
                                        child: ListTile(
                                          leading: filesData[index]['document_link'].substring(
                                                          filesData[index]['document_link']
                                                                  .lastIndexOf(".") +
                                                              1) ==
                                                      'jpg' ||
                                                  filesData[index]['document_link'].substring(
                                                          filesData[index]['document_link']
                                                                  .lastIndexOf(".") +
                                                              1) ==
                                                      'png'
                                              ? const Icon(Icons.image)
                                              : const Icon(Icons.insert_drive_file),
                                          title: Text(filesData[index]['document_name']),
                                          subtitle: Text(
                                              "${camelize(filesData[index]['document_type'].replaceAll('_', ' '))}"),
                                          trailing: checkboxTile(
                                              filesData[index]['document_id'], checkboxBloc),
                                          onTap: () async {
                                            print(filesData[index]['document_link']);
                                            // if(filesData[index]['document_link'].contains('pdf')){
                                            var returnData = await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => PdfView(
                                                  filesData[index]['document_link'],
                                                  filesData[index],
                                                  iHLUserId,
                                                  showExtraButton: true,
                                                ),
                                              ),
                                            );
                                            if (returnData ?? false) {
                                              //refresh the page
                                              getFiles(idAvailable: true);
                                            }
                                          },
                                        ),
                                      ),
                                    );
                                  }),
                            ),
                            SizedBox(height: 1.h),
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryColor,
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                                ),
                                onPressed: () {
                                  Get.to(InsideMedicalFiles(context));
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  width: 40.w,
                                  child: const Text("Upload"),
                                )),
                            SizedBox(height: 1.h),
                            widget.normalFlow
                                ? const SizedBox()
                                : ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primaryColor,
                                      padding:
                                          const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                                    ),
                                    onPressed: () {
                                      if (bState.selectedDocIdList.isNotEmpty) {
                                        if (selectedListNormal.isEmpty) {
                                          debugPrint('No medical files');
                                        } else {
                                          sendReports(
                                              ihlConsultationId: widget.ihlConsultantId,
                                              appointmentId: widget.appointmentId,
                                              selectedDocIdList: selectedListNormal);
                                        }
                                      } else {
                                        Get.snackbar('No Report Selected',
                                            'Please Select at least 1 Report To Send',
                                            icon: const Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Icon(Icons.warning, color: Colors.white),
                                            ),
                                            margin: const EdgeInsets.all(20).copyWith(bottom: 40),
                                            backgroundColor: Colors.red.shade400,
                                            colorText: Colors.white,
                                            duration: const Duration(seconds: 2),
                                            snackPosition: SnackPosition.BOTTOM);
                                      }
                                    },
                                    child: Container(
                                      alignment: Alignment.center,
                                      width: 40.w,
                                      child: const Text("Share File"),
                                    )),
                            SizedBox(height: 3.h)
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            const Center(
                              child: Text(
                                "No files have been uploaded.",
                                style: TextStyle(color: AppColors.primaryColor, fontSize: 20),
                                // subtitle: Text('               Click on the Button Below And\n               Add All Your Medical Files in one\n               Safe and Secure place.'),
                              ),
                            ),
                            SizedBox(
                              height: 5.h,
                            ),
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  primary: AppColors.primaryColor,
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                                ),
                                onPressed: () {
                                  Get.to(InsideMedicalFiles(context));
                                },
                                child: const Padding(
                                  padding: EdgeInsets.all(12.0),
                                  child: Text('Upload'),
                                ))
                          ],
                        )
                  : CommonScreenForNavigation(
                      appBar: AppBar(
                        backgroundColor: AppColors.primaryColor,
                        centerTitle: true,
                        leading: IconButton(
                          icon: const Icon(Icons.arrow_back_ios),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          color: Colors.white,
                        ),
                        title: Text(
                          widget.category,
                          style: const TextStyle(color: Colors.white, fontSize: 25),
                        ),
                      ),
                      contentColor: '',
                      content: SingleChildScrollView(
                        child: filesData.length > 0
                            ? Column(
                                children: <Widget>[
                                  SizedBox(
                                    height: 68.h,
                                    child: ListView.builder(
                                        itemCount: filesData.length,
                                        itemBuilder: (context, index) {
                                          return Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Card(
                                              elevation: 4,
                                              child: ListTile(
                                                leading: filesData[index]['document_link']
                                                                .substring(filesData[index]
                                                                            ['document_link']
                                                                        .lastIndexOf(".") +
                                                                    1) ==
                                                            'jpg' ||
                                                        filesData[index]['document_link'].substring(
                                                                filesData[index]['document_link']
                                                                        .lastIndexOf(".") +
                                                                    1) ==
                                                            'png'
                                                    ? const Icon(Icons.image)
                                                    : const Icon(Icons.insert_drive_file),
                                                title: Text(filesData[index]['document_name']),
                                                subtitle: Text(
                                                    "${camelize(filesData[index]['document_type'].replaceAll('_', ' '))}"),
                                                trailing: checkboxTile(
                                                    filesData[index]['document_id'], checkboxBloc),
                                                onTap: () async {
                                                  print(filesData[index]['document_link']);
                                                  // if(filesData[index]['document_link'].contains('pdf')){
                                                  var returnData = await Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => PdfView(
                                                        filesData[index]['document_link'],
                                                        filesData[index],
                                                        iHLUserId,
                                                        showExtraButton: true,
                                                      ),
                                                    ),
                                                  );
                                                  if (returnData ?? false) {
                                                    //refresh the page
                                                    getFiles(idAvailable: true);
                                                  }
                                                },
                                              ),
                                            ),
                                          );
                                        }),
                                  ),
                                  ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        primary: AppColors.primaryColor,
                                        padding:
                                            const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                                      ),
                                      onPressed: () {
                                        Get.to(InsideMedicalFiles(context));
                                      },
                                      child: const Padding(
                                        padding: EdgeInsets.all(12.0),
                                        child: Text('Upload'),
                                      )),
                                  SizedBox(
                                    height: 5.h,
                                  ),
                                  widget.normalFlow
                                      ? const SizedBox()
                                      : Center(
                                          child: SizedBox(
                                              width: 40.w,
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(4.0),
                                                  ),
                                                  primary: AppColors.primaryColor,
                                                  textStyle: const TextStyle(color: Colors.white),
                                                ),
                                                child: const Text('SHARE FILE',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                    )),
                                                onPressed: () {
                                                  if (bState.selectedDocIdList.isNotEmpty) {
                                                    if (selectedListNormal.isEmpty) {
                                                      print('fghjkl');
                                                    } else {
                                                      sendReports(
                                                          ihlConsultationId: widget.ihlConsultantId,
                                                          appointmentId: widget.appointmentId,
                                                          selectedDocIdList: selectedListNormal);
                                                    }
                                                  } else {
                                                    Get.snackbar('No Report Selected',
                                                        'Please Select at least 1 Report To Send',
                                                        icon: const Padding(
                                                          padding: EdgeInsets.all(8.0),
                                                          child: Icon(Icons.warning,
                                                              color: Colors.white),
                                                        ),
                                                        margin: const EdgeInsets.all(20)
                                                            .copyWith(bottom: 40),
                                                        backgroundColor: Colors.red.shade400,
                                                        colorText: Colors.white,
                                                        duration: const Duration(seconds: 2),
                                                        snackPosition: SnackPosition.BOTTOM);
                                                  }
                                                },
                                              )),
                                        ),
                                  SizedBox(
                                    height: 15.h,
                                  )
                                ],
                              )
                            : SizedBox(
                                height: 100.h,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    const Center(
                                      child: Text(
                                        'No files have been uploaded.',
                                        style:
                                            TextStyle(color: AppColors.primaryColor, fontSize: 20),
                                        // subtitle: Text('               Click on the Button Below And\n               Add All Your Medical Files in one\n               Safe and Secure place.'),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 5.h,
                                    ),
                                    ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          primary: AppColors.primaryColor,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 4),
                                        ),
                                        onPressed: () {
                                          Get.to(InsideMedicalFiles(context));
                                        },
                                        child: const Padding(
                                          padding: EdgeInsets.all(12.0),
                                          child: Text('Upload'),
                                        ))
                                  ],
                                ),
                              ),
                      ),
                    );
            }));
  }

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
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.only(topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0)),
      ),
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter mystate) {
            return Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    fileSelected == false
                        ? Padding(
                            padding: const EdgeInsets.all(12.0).copyWith(left: 16),
                            child: const AutoSizeText(
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
                              style: const TextStyle(
                                  color: AppColors.appTextColor, //AppColors.primaryColor
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold),
                              textAlign: TextAlign.left,
                            ),
                          ),
                    Visibility(
                      visible: fileSelected == false,
                      child: const Divider(
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
                          autovalidateMode: AutovalidateMode.always,
                          controller: fileNameController,
                          validator: (v) {
                            if (v == null) {
                              return null;
                            }
                            if (v.length < 1) {
                              return 'File Name is required';
                            }
                            if (v.length < 4) {
                              return 'File Name should be at least 4 character long';
                            }
                            if (filesNameList.contains(v)) {
                              return 'File Name should be Unique';
                            }
                            return null;
                          },
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
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 15, horizontal: 18),
                            labelText: "Enter file name",
                            errorText: fileNameValidator(fileNametext),
                            fillColor: Colors.red,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.0),
                                borderSide: const BorderSide(color: Colors.blueGrey)),
                          ),
                          maxLines: 1,
                          style: const TextStyle(fontSize: 16.0),
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
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        // color: widget.mealtype!=null?HexColor(widget.mealtype.startColor):AppColors.primaryColor,
                                        width: 2.0,
                                      ),
                                    ),
                                  ),
                                ),
                                style: const TextStyle(color: Colors.white),
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
                                    child: Card(
                                      elevation: 4,
                                      child: Text(
                                        camelize(value.replaceAll('_', ' ')),
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                                hint: const Text(
                                  "Select File Type",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                                ),
                                onChanged: (String value) {
                                  mystate(() {
                                    _chosenType = value;
                                  });
                                  //open file picker
                                  // if(fileNameValidator(fileNametext)==null){
                                  //   Navigator.of(context).pop();
                                  //   sheetForSelectingReport(context);
                                  //   // _openFileExplorer('upload');
                                  //
                                  //   // showDialog(
                                  //   //   context: context,
                                  //   //   builder: (ctx) => AlertDialog(
                                  //   //     title: Text("Alert Dialog Box"),
                                  //   //     content: Text("You have raised a Alert Dialog Box"),
                                  //   //     actions: <Widget>[
                                  //   //       FlatButton(
                                  //   //         onPressed: () {
                                  //   //           Navigator.of(ctx).pop();
                                  //   //         },
                                  //   //         child: Text("okay"),
                                  //   //       ),
                                  //   //     ],
                                  //   //   ),
                                  //   // );
                                  // }
                                  // else{
                                  //   fileNameValidator(fileNametext);
                                  // }
                                },
                              ),
                            ),
                          )
                        : Row(
                            children: <Widget>[
                              MaterialButton(
                                child: const Text(
                                  'Change',
                                  style: TextStyle(
                                      color: AppColors.primaryColor, //AppColors.primaryColor
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                ),
                                onPressed: () {
                                  //open file explorer again
                                  Navigator.of(context).pop();
                                  sheetForSelectingReport(context);
                                },
                              ),
                              MaterialButton(
                                child: const Text(
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
                                    builder: (ctx) => const AlertDialog(
                                      title: Text("Uploading..."),
                                      content: Text("Please Wait. The File is Uploading.."),
                                      actions: <Widget>[
                                        Center(
                                            child: Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: CircularProgressIndicator(),
                                        )),
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
                            textStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
                          ),
                          onPressed: () async {
                            if (fileNameValidator(fileNametext) == null &&
                                fileNametext.length != 0) {
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
                            style:
                                TextStyle(color: Colors.white, letterSpacing: 1.5, fontSize: 16.sp),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 15.h),
                  ],
                ),
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
      shape: const RoundedRectangleBorder(
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
                children: <Widget>[
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
                  Platform.isIOS
                      ? ListTile(
                          title: const Text('Select Report From Storage'),
                          leading: const Icon(Icons.image),
                          onTap: () {
                            sheetForSelectingPdfOrImageIos(context);
                          },
                        )
                      : ListTile(
                          title: const Text('Select Report From Storage'),
                          leading: const Icon(Icons.image),
                          onTap: () async {
                            var status = await CheckPermissions.filePermissions(context);
                            if (status) {
                              _openFileExplorer('upload');
                            }
                          },
                        ),
                  ListTile(
                    title: const Text('Capture Report From Camera'),
                    leading: const Icon(Icons.camera_alt_outlined),
                    onTap: () async {
                      var status = await CheckPermissions.cameraPermissions(context);
                      if (status) {
                        await _imgFromCamera();
                        Navigator.of(context).pop();
                        showFileTypePicker(context);
                        setState(() {
                          fileSelected = true;
                        });
                      }
                    },
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            );
          },
        );
      },
    );
  }

  sheetForSelectingPdfOrImageIos(BuildContext context) {
    // ignore: missing_return
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
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
                children: <Widget>[
                  ListTile(
                    title: const Text('Pdf'),
                    leading: const Icon(Icons.picture_as_pdf_rounded),
                    onTap: () {
                      _openFileExplorer('upload');
                    },
                  ),
                  ListTile(
                    title: const Text('Image'),
                    leading: const Icon(Icons.image),
                    onTap: () {
                      onGallery(context);
                    },
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void onGallery(BuildContext cont) async {
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
      getIMG(source: ImageSource.gallery, context: cont);
      //Navigator.of(context).pop();
    } else if (await permission.request().isDenied) {
      await permission.request();
      Get.snackbar('Gallery Access Denied', 'Allow Photos/Storage permission to continue',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
          isDismissible: false,
          mainButton: TextButton(
              style: TextButton.styleFrom(backgroundColor: Colors.white),
              onPressed: () async {
                await openAppSettings();
              },
              child: const Text('Allow')));
    } else {
      Get.snackbar('Gallery Access Denied', 'Allow Photos/Storage permission to continue',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
          isDismissible: false,
          mainButton: TextButton(
              style: TextButton.styleFrom(backgroundColor: Colors.white),
              onPressed: () async {
                await openAppSettings();
              },
              child: const Text('Allow')));
    }
  }

  _pickImage({ImageSource source, BuildContext context}) async {
    final picked = await ImagePicker().getImage(
      source: source,
      maxHeight: 720,
      maxWidth: 720,
      imageQuality: 80,
    );

    if (picked != null) {
      File selected = await FlutterExifRotation.rotateImage(path: picked.path);
      if (selected != null) {
        return selected;
      }
    }
  }

  Future<void> getIMG({ImageSource source, BuildContext context}) async {
    File fromPickImage = await _pickImage(context: context, source: source);
    if (fromPickImage != null) {
      File cropped = await crop(fromPickImage);
      print(cropped.path);
      //upload(cropped, context);
      if (cropped != null) {
        croppedFile = cropped;
        if (this.mounted) {
          setState(() {
            fileSelected = true;
            isImageSelectedFromCamera = true;
          });
        }
        int count = 0;
        Navigator.popUntil(context, (route) {
          return count++ == 2;
        });
        showFileTypePicker(context);
      }
    } else {
      loading = false;
    }
  }

  Future<File> crop(File selectedfile) async {
    try {
      File toSend;
      await ImageCropper().cropImage(sourcePath: selectedfile.path, uiSettings: [
        AndroidUiSettings(
          lockAspectRatio: false,
          activeControlsWidgetColor: AppColors.primaryAccentColor,
          backgroundColor: AppColors.appBackgroundColor,
          toolbarColor: AppColors.primaryAccentColor,
          toolbarWidgetColor: Colors.white,
          toolbarTitle: 'Crop Image',
        ),
        IOSUiSettings(
          title: 'Crop image',
        )
      ]).then((value) => toSend = File(value.path));
      if (toSend == null) {
        return selectedfile;
      } else
        return toSend;
    } catch (e) {
      return selectedfile;
    }
  }

  ///capture report from camera
  bool isImageSelectedFromCamera = false;

  File croppedFile;
  File _image;
  final picker = ImagePicker();

  _imgFromCamera() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    // final pickedFile = await picker.getImage(source: ImageSource.camera);
    _image = File(pickedFile.path);
    await ImageCropper().cropImage(
        sourcePath: _image.path,
        aspectRatio: const CropAspectRatio(ratioX: 12, ratioY: 16),
        maxWidth: 512,
        maxHeight: 512,
        compressFormat: ImageCompressFormat.png,
        compressQuality: 60,
        uiSettings: [
          AndroidUiSettings(
            lockAspectRatio: false,
            activeControlsWidgetColor: AppColors.primaryAccentColor,
            toolbarTitle: 'Crop the Image',
            toolbarColor: const Color(0xFF19a9e5),
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
      });

      if (type == 'upload') {
        Navigator.pop(context);
        showFileTypePicker(context);
      } else {
        editDocuments(edit_doc_id, edit_doc_type);
      }
    } else {
      // User canceled the picker
    }
  }

  //api call
  //  apiCall(){
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
          '${camelize(fileNametext.replaceAll('.', '') + '.' + extension.toLowerCase().replaceAll('.', ''))} uploaded successfully.',
          icon: const Padding(
              padding: EdgeInsets.all(8.0), child: Icon(Icons.check_circle, color: Colors.white)),
          margin: const EdgeInsets.all(20).copyWith(bottom: 40),
          backgroundColor: AppColors.primaryAccentColor,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
          snackPosition: SnackPosition.BOTTOM);
      getFiles();
    } else {
      Get.snackbar('File not uploaded', 'Encountered some error while uploading. Please try again',
          icon: const Padding(
              padding: EdgeInsets.all(8.0), child: Icon(Icons.cancel_rounded, color: Colors.white)),
          margin: const EdgeInsets.all(20).copyWith(bottom: 40),
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  //delete api
  deleteFile(String documentId, String filename) async {
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
      if (output['status'] == 'document deleted successfully') {
        //snackbar
        Get.snackbar('Deleted!', '${camelize(filename)} deleted successfully.',
            icon: const Padding(
                padding: EdgeInsets.all(8.0), child: Icon(Icons.check_circle, color: Colors.white)),
            margin: const EdgeInsets.all(20).copyWith(bottom: 40),
            backgroundColor: AppColors.primaryAccentColor,
            colorText: Colors.white,
            duration: const Duration(seconds: 5),
            snackPosition: SnackPosition.BOTTOM);
        getFiles();
      } else {
        Get.snackbar('File not deleted', 'Encountered some error while deleting. Please try again',
            icon: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(Icons.cancel_rounded, color: Colors.white),
            ),
            margin: const EdgeInsets.all(20).copyWith(bottom: 40),
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: const Duration(seconds: 5),
            snackPosition: SnackPosition.BOTTOM);
      }
    } else {
      print(response.body);
    }
  }

  Future editDocuments(String docmentId, String doctype) async {
    String filename = file.name, extension = file.extension, path = file.path;
    print('editDocuments apicalll');
    //take the image from filemanager
    print('new file name =' + file.name);
    final finalOutput = await MedicalFilesApi.editDocumentsApi(
        filename: filename,
        docmentId: docmentId,
        doctype: doctype,
        extension: extension,
        iHLUserId: iHLUserId,
        path: path);

    print(finalOutput['status']);
    if (finalOutput['status'] == 'document edited successfully') {
      //snackbar
      snackBarForSuccess(snackName: 'Updated', fileName: filename);
      setState(() {
        fileSelected = false;
      });
      getFiles();
    } else {
      snackBarForError(fileName: filename, snackName: 'edit');
      setState(() {
        fileSelected = false;
      });
      // Get.snackbar('File not edited',
      //     'Encountered some error while editing. Please try again',
      //     icon: Padding(
      //         padding: const EdgeInsets.all(8.0),
      //         child: Icon(Icons.cancel_rounded, color: Colors.white)),
      //     margin: EdgeInsets.all(20).copyWith(bottom: 40),
      //     backgroundColor: Colors.red,
      //     colorText: Colors.white,
      //     duration: Duration(seconds: 5),
      //     snackPosition: SnackPosition.BOTTOM);
    }
  }

  Widget InsideMedicalFiles(BuildContext context) {
    GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    fileNameController.clear();

    return Form(
      key: _formKey,
      child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () async {
                Get.back();
              }, //replaces the screen to Main dashboard
              color: Colors.white,
            ),
            title: const Text("Upload new files"),
            backgroundColor: AppColors.primaryColor,
          ),
          body: StatefulBuilder(builder: (BuildContext context, StateSetter mystate) {
            return Center(
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    fileSelected == false
                        ? Padding(
                            padding: const EdgeInsets.all(12.0).copyWith(left: 16),
                            child: const Align(
                              alignment: Alignment.topLeft,
                              child: AutoSizeText(
                                // 'Select File Type',
                                'Upload File',
                                style: TextStyle(
                                    color: AppColors.primaryColor, //AppColors.primaryColor
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.left,
                              ),
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.all(12.0).copyWith(left: 16),
                            child: AutoSizeText(
                              '${fileNametext + "." + "${isImageSelectedFromCamera ? 'jpg' : file.extension.toLowerCase()}"}',
                              style: const TextStyle(
                                  color: AppColors.appTextColor, //AppColors.primaryColor
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold),
                              textAlign: TextAlign.left,
                            ),
                          ),
                    Visibility(
                      visible: fileSelected == false,
                      child: Padding(
                        padding:
                            const EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0, bottom: 10.0),
                        child: TextFormField(
                          autovalidateMode: AutovalidateMode.always,
                          controller: fileNameController,
                          validator: (v) {
                            if (v == null) {
                              return null;
                            }
                            if (v.contains('"')) {
                              return 'File Name should not contains double quotes';
                            }
                            if (v.length < 1) {
                              return 'File Name is required';
                            }
                            if (v.length < 4) {
                              return 'File Name should be at least 4 character long';
                            }
                            if (filesNameList.contains(v)) {
                              return 'File Name should be Unique';
                            } else {
                              return null;
                            }
                          },
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
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 15, horizontal: 18),
                            labelText: "Enter file name",
                            errorText: fileNameValidator(fileNametext),
                            fillColor: Colors.red,
                            border: new OutlineInputBorder(
                                borderRadius: new BorderRadius.circular(15.0),
                                borderSide: new BorderSide(color: Colors.blueGrey)),
                          ),
                          maxLines: 1,
                          style: const TextStyle(fontSize: 16.0),
                          textInputAction: TextInputAction.done,
                        ),
                      ),
                    ),
                    fileSelected == false
                        ? Padding(
                            padding: const EdgeInsets.all(10.0).copyWith(left: 24, right: 24),
                            child: Container(
                              child: DropdownButton<String>(
                                selectedItemBuilder: (BuildContext context) {
                                  return <String>[
                                    'lab_report',
                                    'x_ray',
                                    'ct_scan',
                                    'mri_scan',
                                    'others'
                                  ].map<Widget>((String item) {
                                    print("$item");
                                    return DropdownMenuItem(
                                      value: item,
                                      child: Center(
                                        child: Text(
                                          camelize(item.replaceAll('_', ' ')),
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList();
                                },
                                iconSize: 30,
                                focusColor: Colors.white,
                                value: _chosenType,
                                isExpanded: true,
                                underline: Container(
                                  height: 2.0,
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Colors.grey,
                                        // color: widget.mealtype!=null?HexColor(widget.mealtype.startColor):AppColors.primaryColor,
                                        width: 2.0,
                                      ),
                                    ),
                                  ),
                                ),
                                style: const TextStyle(color: Colors.white),
                                iconEnabledColor: AppColors.primaryColor,
                                items: <String>[
                                  'lab_report',
                                  'x_ray',
                                  'ct_scan',
                                  'mri_scan',
                                  'others'
                                ].map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Container(
                                      height: 5.h,
                                      width: 90.w,
                                      child: Card(
                                        elevation: 3,
                                        child: Center(
                                          child: Text(
                                            camelize(value.replaceAll('_', ' ')),
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                                hint: const Text(
                                  "Select File Type",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                                ),
                                onChanged: (String value) {
                                  mystate(() {
                                    _chosenType = value;
                                  });
                                },
                              ),
                            ),
                          )
                        : Row(
                            children: <Widget>[
                              MaterialButton(
                                child: const Text(
                                  'Change',
                                  style: TextStyle(
                                      color: AppColors.primaryColor, //AppColors.primaryColor
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                ),
                                onPressed: () {
                                  //open file explorer again
                                  Navigator.of(context).pop();
                                  sheetForSelectingReport(context);
                                },
                              ),
                              MaterialButton(
                                child: const Text(
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
                                    builder: (ctx) => const AlertDialog(
                                      title: Text("Uploading..."),
                                      content: Text("Please Wait. The File is Uploading..."),
                                      actions: <Widget>[
                                        Center(
                                            child: Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: CircularProgressIndicator(),
                                        )),
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
                              borderRadius: BorderRadius.circular(2.0),
                            ),
                            // primary: Colors.green.withOpacity(1),
                            // primary: AppColors.primaryColor,
                            primary: AppColors.primaryAccentColor,
                            textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                          onPressed: () async {
                            if (_formKey.currentState.validate()) {
                              if (fileNameValidator(fileNametext) == null &&
                                  fileNametext.length != 0) {
                                Navigator.of(context).pop();
                                sheetForSelectingReport(context);
                              } else {
                                fileNameValidator(fileNametext);
                                FocusManager.instance.primaryFocus?.unfocus();
                              }
                            }
                          },
                          child: Text(
                            ' UPLOAD ',
                            style: TextStyle(color: Colors.white, fontSize: 15.sp),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 15.h),
                  ],
                ),
              ),
            );
          })),
    );
  }

  sendReports(
      {String ihlConsultationId, String appointmentId, List<String> selectedDocIdList}) async {
    String response = await TeleConsultationFunctionsAndVariables.shareMedicalDocAfterAppointment(
        selectedDocIdList: selectedDocIdList,
        appointmentId: appointmentId,
        ihl_consultant_id: ihlConsultationId);
    if (response.contains("document uploaded successfully")) {
      Map<String, dynamic> attributes = <String, dynamic>{
        'data': {
          'ihl_user_id': "$iHLUserId",
          "document_id": selectedDocIdList,
          "appointment_id": widget.appointmentId.toString().replaceAll('ihl_consultant_', ''),
          "ihl_consultant_id": widget.ihlConsultantId,
        }
      };

      ///Adding the medical file document to the firestore ⚪
      try {
        await FireStoreCollections.medicalCollection.doc(appointmentId).set(attributes);
      } catch (e) {
        debugPrint(e.toString());
      }
      Get.snackbar('Report ', 'Sent Successfully',
          icon: const Padding(
              padding: EdgeInsets.all(8.0), child: Icon(Icons.check_circle, color: Colors.white)),
          margin: const EdgeInsets.all(20).copyWith(bottom: 40),
          backgroundColor: AppColors.primaryAccentColor,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Widget checkboxTile(String docId, MedFileBloc checkboxBloc) {
    return BlocProvider(
      create: (BuildContext context) => MedFileBloc()..add(AddMedFileEvent()),
      child:
          BlocBuilder<MedFileBloc, MedFileState>(builder: (BuildContext ctx, MedFileState bState) {
        final MedFileBloc updateBloc = BlocProvider.of<MedFileBloc>(ctx);
        return Checkbox(
          value: bState.selectedDocIdList.contains(docId.toString())
              ? true
              : false, //if this is in the list than add it or remove it
          onChanged: (dynamic value) {
            print(value);

            ///first check in the list and than
            ///if that item is available in the list already than => remove it from the list ,
            ///if item is not there in the list than add it
            if (bState.selectedDocIdList.contains(docId.toString())) {
              ///chechbox removes if file contains inside
              updateBloc.add(RemoveMedFileEvent(docid: docId.toString()));
              selectedListNormal.remove(docId.toString());
              // bState.selectedDocIdList.remove(docId);
            } else {
              ///chechbox add if file not contains inside
              updateBloc.add(AddMedFileEvent(docid: docId.toString()));
              selectedListNormal.add(docId.toString());
              // bState.selectedDocIdList.add(docId);
            }
            print('=========$selectedListNormal');
          },
        );
      }),
    );
  }

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
    return null;
  }
}
