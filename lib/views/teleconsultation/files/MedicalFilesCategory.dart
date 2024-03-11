import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:ihl/constants/api.dart';
import 'package:ihl/constants/app_texts.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/utils/screenutil.dart';
import 'package:ihl/views/teleconsultation/files/file_resuable_snackbar.dart';
import 'package:ihl/widgets/ScrollessBasicPageUI.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:strings/strings.dart';

import 'medicalFiles.dart';

class MedicalFilesCategory extends StatefulWidget {
  @override
  _MedicalFilesCategoryState createState() => _MedicalFilesCategoryState();
}

class _MedicalFilesCategoryState extends State<MedicalFilesCategory> {
  http.Client _client = http.Client(); //3gb
  List<Map> fileTree = [];
  Map fileStructure = {};
  bool loading = false; //true
  getCurrentFolder() {}
  var _chosenType = 'others';
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
        style: TextStyle(color: Colors.black),
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

    ///register a send port for the other isolates
    // IsolateNameServer.registerPortWithName(_receivePort.sendPort, "downloading");
    //
    //
    // ///Listening for the data is comming other isolataes
    // _receivePort.listen((message) {
    //   if(this.mounted){setState(() {
    //     progress = message[2];
    //   });}
    //
    //   print(progress);
    // });
    //
    //
    // FlutterDownloader.registerCallback(downloadingCallback);
    // getFiles();
  }

  Widget FileOBJ(Map map, BuildContext cont) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(
          Icons.description,
          size: 100,
          color: AppColors.primaryAccentColor,
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
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
                child: Icon(Icons.more_vert),
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
                            children: [
                              Container(
                                color: AppColors.cardColor,
                                child: Column(
                                  children: [
                                    ListTile(
                                      leading: Icon(Icons.edit),
                                      title: Text('Rename'),
                                      onTap: () {},
                                    ),
                                    Divider(),
                                    ListTile(
                                      leading: Icon(Icons.delete),
                                      title: Text('Delete'),
                                      onTap: () {},
                                    ),
                                    Divider(),
                                    ListTile(
                                      leading: Icon(Icons.info),
                                      title: Text('Details'),
                                      onTap: () {},
                                    ),
                                    Divider(),
                                    ListTile(
                                      leading: Icon(Icons.share),
                                      title: Text('Share'),
                                      onTap: () {},
                                    ),
                                    Divider(),
                                    ListTile(
                                      leading: Icon(Icons.close),
                                      title: Text('Cancel'),
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
        children: [
          Icon(
            Icons.folder,
            size: 100,
            color: AppColors.primaryAccentColor,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
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
                  child: Icon(Icons.more_vert),
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
                              children: [
                                Container(
                                  color: AppColors.cardColor,
                                  child: Column(
                                    children: [
                                      ListTile(
                                        leading: Icon(Icons.edit),
                                        title: Text('Rename'),
                                        onTap: () {},
                                      ),
                                      Divider(),
                                      ListTile(
                                        leading: Icon(Icons.delete),
                                        title: Text('Delete'),
                                        onTap: () {},
                                      ),
                                      Divider(),
                                      ListTile(
                                        leading: Icon(Icons.info),
                                        title: Text('Details'),
                                        onTap: () {},
                                      ),
                                      Divider(),
                                      ListTile(
                                        leading: Icon(Icons.share),
                                        title: Text('Share'),
                                        onTap: () {},
                                      ),
                                      Divider(),
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

  Widget screen(Widget body) {
    return WillPopScope(
      onWillPop: () async {
        if (fileTree.length > 1) {
          fileTree.removeLast();
          loadForMilliSeconds(200);
          if (this.mounted) {
            setState(() {});
            return false;
          }
        }
        return true;
      },
      child: ScrollessBasicPageUI(
          appBar: Column(
            children: [
              SizedBox(
                width: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    color: Colors.white,
                  ),
                  Text(
                    AppTexts.teleConDashboardFiles,
                    style: TextStyle(color: Colors.white, fontSize: 25),
                  ),
                  SizedBox(
                    width: 40,
                  )
                ],
              ),
            ],
          ),
          body: body),
    );
  }

  var filesData;
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
      body: jsonEncode(<String, String>{
        'ihl_user_id': "$iHLUserId", //"soTlvURs30uyrVP8osAZeQ",
      }),
    );
    print('${getUserFile.statusCode}');
    if (getUserFile.statusCode == 200) {
      filesData = json.decode(getUserFile.body);
      setState(() {
        loading = false;
        filesData;
      });
      for (int i = 0; i < filesData.length; i++) {
        var name;
        if (filesData[i]['document_name'].toString().contains('.')) {
          var parse1 = filesData[i]['document_name'].toString().replaceAll('.jpg', '');
          var parse2 = parse1.replaceAll('.jpeg', '');
          var parse3 = parse2.replaceAll('.png', '');
          var parse4 = parse3.replaceAll('.pdf', '');
          name = parse4;
        }
        filesNameList.add(name);
      }
      print(getUserFile.body);
    } else {
      print(getUserFile.body);
    }
  }

  final List<Map> options = [
    {
      'text': "Lab Report",
      'icon': FontAwesomeIcons.file,
      'iconSize': 24.0,
      'onTap': (BuildContext context) {},
      'color': AppColors.startConsult,
    },
    {
      'text': 'X Ray',
      'icon': FontAwesomeIcons.file,
      'iconSize': 24.0,
      'onTap': (BuildContext context) {},
      'color': AppColors.startConsult,
    },
    {
      'text': 'CT Scan',
      'icon': FontAwesomeIcons.file,
      'iconSize': 24.0,
      'onTap': (BuildContext context) {},
      'color': AppColors.startConsult,
    },
    {
      'text': 'MRI Scan',
      'icon': FontAwesomeIcons.file,
      'iconSize': 24.0,
      'onTap': (BuildContext context) {},
      'color': AppColors.startConsult,
    },
    {
      'text': "Others",
      'icon': FontAwesomeIcons.file,
      'iconSize': 24.0,
      'onTap': (BuildContext context) {},
      'color': AppColors.startConsult,
    },
  ];

  @override
  Widget build(BuildContext context) {
    ScUtil.init(context, width: 360, height: 640, allowFontScaling: true);
    if (loading) {
      return screen(Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: screen(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  child: ListView.builder(
                    physics: const ScrollPhysics(),
                    primary: false,
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (BuildContext context, int index) {
                      return medFileCard(
                        context,
                        options[index]['text'],
                        options[index]['icon'],
                        options[index]['iconSize'],
                        options[index]['color'],
                        () {
                          Get.to(MedicalFiles(
                              category: options[index]['text'],
                              medicalFiles: false,
                              consultStages: false));
                          // options[index]['onTap'](context);
                        },
                      );
                    },
                  ),
                ),
                //ConsultationHistory(),
              ],
            ),
          ),
        ),
      ),
    );
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
                                //open file picker
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
                                Navigator.of(context).pop();
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
                  ListTile(
                    title: Text('Select Report From Storage'),
                    leading: Icon(Icons.image),
                    onTap: () {
                      _openFileExplorer('upload');
                    },
                  ),
                  ListTile(
                    title: Text('Capture Report From Camera'),
                    leading: Icon(Icons.camera_alt_outlined),
                    onTap: () async {
                      await _imgFromCamera();
                      Navigator.of(context).pop();
                      showFileTypePicker(context);
                      setState(() {
                        fileSelected = true;
                      });
                    },
                  ),
                  SizedBox(height: 30),
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

  Future<void> _openFileExplorer(type, {edit_doc_id, edit_doc_type}) async {
    result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'pdf'],
    );

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
          '${camelize(fileNametext.replaceAll('.', '') + '.' + extension.toLowerCase())} uploaded successfully.',
          icon: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(Icons.check_circle, color: Colors.white)),
          margin: EdgeInsets.all(20).copyWith(bottom: 40),
          backgroundColor: AppColors.primaryAccentColor,
          colorText: Colors.white,
          duration: Duration(seconds: 5),
          snackPosition: SnackPosition.BOTTOM);
      getFiles();
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

  //delete api
  deleteFile(String documentId, String filename) async {
    final response = await _client.post(
      Uri.parse(API.iHLUrl + "/consult/delete_medical_document"),
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
            icon: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(Icons.check_circle, color: Colors.white)),
            margin: EdgeInsets.all(20).copyWith(bottom: 40),
            backgroundColor: AppColors.primaryAccentColor,
            colorText: Colors.white,
            duration: Duration(seconds: 5),
            snackPosition: SnackPosition.BOTTOM);
        getFiles();
      } else {
        Get.snackbar('File not deleted', 'Encountered some error while deleting. Please try again',
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
    }
  }

  Widget medFileCard(BuildContext context, var _title, var _icon, var _iconSize, var _bgColor,
      final Function onTap) {
    return Padding(
      padding: const EdgeInsets.all(2.5),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 4,
        color: AppColors.cardColor,
        child: InkWell(
          borderRadius: BorderRadius.circular(15.0),
          onTap: onTap,
          splashColor: _bgColor.withOpacity(0.5),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            SizedBox(
              height: ScUtil().setHeight(3.0),
            ),
            Center(
              child: Row(
                children: [
                  Container(
                    margin: const EdgeInsets.all(11.0),
                    height: ScUtil().setHeight(30.0),
                    width: ScUtil().setWidth(50.0),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      _icon,
                      color: _bgColor,
                      size: _iconSize,
                    ),
                  ),
                  SizedBox(
                    width: ScUtil().setWidth(30.0),
                  ),
                  Flexible(
                    child: Text(
                      _title,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        //fontWeight: FontWeight.w600,
                        fontSize: 18,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: ScUtil().setHeight(3.0),
            ),
          ]),
        ),
      ),
    );
  }
}
