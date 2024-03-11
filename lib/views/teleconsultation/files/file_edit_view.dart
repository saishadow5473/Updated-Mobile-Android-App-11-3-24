import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:get/get.dart';
import 'package:ihl/constants/api.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:path_provider/path_provider.dart';
import 'package:strings/strings.dart';
import 'file_resuable_snackbar.dart';
import 'package:http/http.dart' as http;
// import 'package:pdf/widgets.dart';

class FileEditView extends StatefulWidget {
  FileEditView(this.link, this.docObject, this.iHLUserId, {this.showExtraButton});

  var link;
  var docObject;
  final iHLUserId;
  var showExtraButton;

  @override
  _FileEditViewState createState() => new _FileEditViewState();
}

class _FileEditViewState extends State<FileEditView> {
  http.Client _client = http.Client(); //3gb
  bool refresh = false;
  String pathPDF = "";
  bool loading = true;
  String type = 'pdf';
  FilePickerResult result;
  String oldExt = '';
  String shrinkExt = '';
  File _image;

  // bool fileSelected = false;
  PlatformFile file;

  // PlatformFile existfile;
  String fileNametext = '';
  String pathForImage;
  String _chosenType = 'others';
  TextEditingController fileNameController = TextEditingController();

  @override
  Future<void> initState() {
    if (widget.showExtraButton == null) {
      widget.showExtraButton = true;
    }
    super.initState();
    if (widget.link.substring(widget.link.lastIndexOf(".") + 1) == 'pdf') {
      createFileOfPdfUrl(obj: widget.docObject).then((f) {
        setState(() {
          pathPDF = f.path;
          print(pathPDF);
          loading = false;
          type = 'pdf';
        });
      });
    } else if (widget.link.substring(widget.link.lastIndexOf(".") + 1) == 'jpg' ||
        widget.link.substring(widget.link.lastIndexOf(".") + 1) == 'png') {
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(builder: (context) => ShowImage(widget.link)));
      getImageDetails();
    } else {
      setState(() {
        type = 'format';
        // loading=false;
      });
    }
  }

  getImageDetails() async {
    pathForImage = await MedicalFilesApi.downloadImageForEdit(
        widget.docObject['document_name'], widget.docObject['document_link']);
    print(pathForImage);
    setState(() {
      type = 'image';
      filename = widget.link.substring(widget.link.lastIndexOf("/") + 1);
      oldExt = widget.docObject['document_name']
          .toString()
          .substring(widget.docObject['document_name'].lastIndexOf('.') + 1);
      // print('=========================================================================================$oldExt');
      filenameFieldText = widget.docObject['document_name'].toString().replaceAll('.jpg', '');
      filenameFieldText = filenameFieldText.toString().replaceAll('.png', '');
      fileNameController.text = filenameFieldText ?? 'loading...';
      fileNametext = filenameFieldText;
      _chosenType = widget.docObject['document_type'];
      loading = false;
    });
  }

  bool edit = false;
  bool delete = false;
  var filename;
  var filenameFieldText;

  Future<File> createFileOfPdfUrl({obj}) async {
    // final url = widget.link; //"http://africau.edu/images/default/sample.pdf";
    filename = obj['document_link'].substring(obj['document_link'].lastIndexOf("/") + 1);
    oldExt = obj['document_name']
        .toString()
        .substring(obj['document_name'].toString().lastIndexOf('.') + 1);
    // print('=========================================================================================$oldExt');
    filenameFieldText = obj['document_name'].toString().replaceAll('.pdf', '');
    var request = await HttpClient().getUrl(Uri.parse(obj['document_link']));
    var response = await request.close();
    var bytes = await consolidateHttpClientResponseBytes(response);
    String dir = (await getApplicationDocumentsDirectory()).path;
    File existfile = new File('$dir/$filenameFieldText');
    await existfile.writeAsBytes(bytes);
    // setState(() {
    //
    // });
    fileNameController.text = filenameFieldText ?? 'loading...';
    fileNametext = filenameFieldText;
    _chosenType = obj['document_type'];
    return existfile;
  }

  String fileNameValidator(String ip) {
    if (ip.length < 1) {
      return 'File Name is required';
    }
    if (ip.length < 4) {
      return 'File Name should be at least 4 character long';
    }
    // return null;
  }

  Future<void> _openFileExplorer() async {
    final pickedFile = await ImagePicker().getImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
    // FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      file = result.files.first;
      print(file.name);

      // await saveChanges();
      // print('changes saved');

      // print(file.bytes);
      // print(file.size);
      // print(file.extension);
      // print(file.path);
      // setState(() {
      //   loading=true;
      // });

      // if(type=='upload'){
      //   Navigator.pop(context);
      //   showFileTypePicker(context);
      // }
      // else{
      //   MedicaleditDocuments(edit_doc_id,edit_doc_type);

      // }
    } else {
      // User canceled the picker
    }
  }

  saveChanges() async {
    loading = true;
    setState(() {

    });
    // if (file != null) {
    //   oldExt = file.extension.toLowerCase();
    //   pathForImage = file.path;
    // }
    if (_image != null) {
      pathForImage = _image.path;
    }
    shrinkExt = fileNametext.toString().replaceAll('.jpeg', '');
    //else path for image is giving in ImageDetails function
    final finalOutput = await MedicalFilesApi.editDocumentsApi(
        filename: '$shrinkExt.$oldExt',
        path: pathForImage,
        //file.path,
        extension: oldExt,
        //file.extension.toLowerCase(),//!=null?file.extension?.toLowerCase():'jpg',//oldExt,
        doctype: _chosenType,
        docmentId: widget.docObject['document_id'],
        iHLUserId: widget.iHLUserId);
    edit = true;
    // print(finalOutput['status']);
    if (finalOutput['status'] == 'document edited successfully') {
      //snackbar
      snackBarForSuccess(snackName: 'changed', fileName: shrinkExt); //file.extension.toLowerCase()
      await getFiles(widget.docObject['document_id']);
      // await getFiles(widget.docObject['document_id']);
      setState(() {
        loading = false;
      });
    } else {
      snackBarForError(
          fileName: fileNametext,
          snackName:
          'edit'); //snackBarForError(fileName: fileNametext+'.'+oldExt,snackName: 'edit');//
      setState(() {
        loading = false;
      });
    }
  }

  Future<bool> _willPopCallback() {
    if (edit || delete) {
      refresh = true;
    }
    Navigator.of(context).pop(refresh);
  }

  @override
  Widget build(BuildContext context) {
    if (type == 'image') {
      return WillPopScope(
        onWillPop: _willPopCallback,
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(400),
            child: SafeArea(
              child: Container(
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Text('${filename ?? 'Docs'}'),
                    SizedBox(
                      height: 50,
                      width: double.infinity,
                      child: Card(
                          elevation: 10,
                          margin: EdgeInsets.all(0),

                          // height: 40,
                          // width: double.infinity,

                          color: AppColors.primaryColor,
                          child: ListTile(
                            leading: IconButton(
                              icon: Icon(Icons.arrow_back_ios),
                              color: Colors.white,
                              onPressed: _willPopCallback,
                            ),
                            title: Text(
                              'Edit File',
                              style: TextStyle(color: Colors.white, fontSize: 20),
                            ),
                          )),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 22.0),
                      child: Text(
                        "Change File Name",
                        style: TextStyle(
                          color: AppColors.primaryAccentColor,
                          fontSize: 18.0,
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                      const EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0, bottom: 10.0),
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
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 18),
                          // labelText: '${filename ?? 'Docs'}',
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
                    //change file type
                    Padding(
                      padding: const EdgeInsets.only(left: 22.0),
                      child: Text(
                        "Change File Type",
                        style: TextStyle(
                          color: AppColors.primaryAccentColor,
                          fontSize: 18.0,
                        ),
                      ),
                    ),
                    Padding(
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
                          items: <String>['lab_report', 'x_ray', 'ct_scan', 'mri_scan', 'others']
                              .map<DropdownMenuItem<String>>((String value) {
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
                            setState(() {
                              _chosenType = value;
                            });
                          },
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Spacer(),
                        ElevatedButton(
                          child: Text('Change File'),
                          onPressed: () {
                            if (fileNameValidator(fileNametext) == null) {
                              _openFileExplorer();
                            }
                          },
                        ),
                        Spacer(),
                        ElevatedButton(
                          child: Text('Save Changes'),
                          onPressed: fileNameValidator(fileNametext) == null
                              ? () async {
                            await saveChanges();
                            // setState(() {
                            //   loading = true;
                            // });
                            // // if (file != null) {
                            // //   oldExt = file.extension.toLowerCase();
                            // //   pathForImage = file.path;
                            // // }
                            // if (_image != null) {
                            //   pathForImage = _image.path;
                            // }
                            // //else path for image is giving in ImageDetails function
                            // final finalOutput = await MedicalFilesApi.editDocumentsApi(
                            //     filename: '$fileNametext.$oldExt',
                            //     path: pathForImage,
                            //     //file.path,
                            //     extension: oldExt,
                            //     //file.extension.toLowerCase(),//!=null?file.extension?.toLowerCase():'jpg',//oldExt,
                            //     doctype: _chosenType,
                            //     docmentId: widget.docObject['document_id'],
                            //     iHLUserId: widget.iHLUserId);
                            // edit = true;
                            // // print(finalOutput['status']);
                            // if (finalOutput['status'] == 'document edited successfully') {
                            //   //snackbar
                            //   snackBarForSuccess(
                            //       snackName: 'Updated',
                            //       fileName: shrinkExt); //file.extension.toLowerCase()
                            //   await getFiles(widget.docObject['document_id']);
                            //   // await getFiles(widget.docObject['document_id']);
                            //   setState(() {
                            //     loading = false;
                            //   });
                            //   Navigator.pop(context);
                            // } else {
                            //   snackBarForError(
                            //       fileName: fileNametext,
                            //       snackName:
                            //           'edit'); //snackBarForError(fileName: fileNametext+'.'+oldExt,snackName: 'edit');//
                            //   setState(() {
                            //     loading = false;
                            //   });
                            // }
                          }
                              : () {},
                        ),
                        Spacer(),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // AppBar(
            //   backgroundColor: Colors.blue.shade200,
            //   elevation: 0,
            //   title: Text('${filename ?? 'Docs'}'),
            //   // actions: widget.showExtraButton?<Widget>[
            //   //   // IconButton(
            //   //   //   icon: Icon(Icons.edit),
            //   //   //   onPressed: () {
            //   //   //     _openFileExplorer();
            //   //   //   },
            //   //   // ),
            //   //   // IconButton(
            //   //   //   icon: Icon(Icons.delete),
            //   //   //   onPressed: () async {
            //   //   //     setState(() {
            //   //   //       loading = true;
            //   //   //     });
            //   //   //     final output = await MedicalFilesApi.deleteFileApi(widget.docObject['document_id'],widget.docObject['document_name'],widget.iHLUserId);
            //   //   //
            //   //   //     if (output['status'] == 'document deleted successfully') {
            //   //   //       //snackbar
            //   //   //       // Get.snackbar('Deleted!', '${camelize(filename)} deleted successfully.',
            //   //   //       //     icon: Padding(
            //   //   //       //         padding: const EdgeInsets.all(8.0),
            //   //   //       //         child: Icon(Icons.check_circle, color: Colors.white)),
            //   //   //       //     margin: EdgeInsets.all(20).copyWith(bottom: 40),
            //   //   //       //     backgroundColor: AppColors.primaryAccentColor,
            //   //   //       //     colorText: Colors.white,
            //   //   //       //     duration: Duration(seconds: 5),
            //   //   //       //     snackPosition: SnackPosition.BOTTOM);
            //   //   //       setState(() {
            //   //   //         loading = false;
            //   //   //       });
            //   //   //       refresh = true;
            //   //   //       Navigator.pop(context,refresh);
            //   //   //       // getFiles();
            //   //   //     } else {
            //   //   //       setState(() {
            //   //   //         loading = false;
            //   //   //       });
            //   //   //       Get.snackbar('File not deleted',
            //   //   //           'Encountered some error while deleting. Please try again',
            //   //   //           icon: Padding(
            //   //   //             padding: const EdgeInsets.all(8.0),
            //   //   //             child: Icon(Icons.cancel_rounded, color: Colors.white),),
            //   //   //           margin: EdgeInsets.all(20).copyWith(bottom: 40),
            //   //   //           backgroundColor: Colors.red,
            //   //   //           colorText: Colors.white,
            //   //   //           duration: Duration(seconds: 5),
            //   //   //           snackPosition: SnackPosition.BOTTOM);
            //   //   //     }
            //   //   //
            //   //   //   },
            //   //   // ),
            //   // ]:[],
            // ),any
          ),
          body: !loading ? Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                  image:
                  _image == null ? NetworkImage(widget.link) : FileImage(_image)
              ),
            ),
          ) : Center(
              child: CircularProgressIndicator()),
        ),
      );
    } else if (type == 'format') {
      return Scaffold(
          body: Container(
            child: Center(
              child: Text('Format Not Showed'),
            ),
          ));
    }
    else {
      return WillPopScope(
        onWillPop: _willPopCallback,
        child: Scaffold(
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(400),
              child: SafeArea(
                child: Container(
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Text('${filename ?? 'Docs'}'),
                      SizedBox(
                        height: 50,
                        width: double.infinity,
                        child: Card(
                            elevation: 10,
                            margin: EdgeInsets.all(0),

                            // height: 40,
                            // width: double.infinity,

                            color: AppColors.primaryColor,
                            child: ListTile(
                              leading: IconButton(
                                icon: Icon(Icons.arrow_back_ios),
                                color: Colors.white,
                                onPressed: () => Get.back(),
                              ),
                              title: Text(
                                'Edit File',
                                style: TextStyle(color: Colors.white, fontSize: 20),
                              ),
                            )),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 22.0),
                        child: Text(
                          "Change File Name",
                          style: TextStyle(
                            color: AppColors.primaryAccentColor,
                            fontSize: 18.0,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 20.0, right: 20.0, top: 10.0, bottom: 10.0),
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
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 18),
                            // labelText: '${filename ?? 'Docs'}',
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
                      //change file type
                      Padding(
                        padding: const EdgeInsets.only(left: 22.0),
                        child: Text(
                          "Change File Type",
                          style: TextStyle(
                            color: AppColors.primaryAccentColor,
                            fontSize: 18.0,
                          ),
                        ),
                      ),
                      Padding(
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
                              setState(() {
                                _chosenType = value;
                              });
                            },
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Spacer(),
                          ElevatedButton(
                            child: Text('Change File'),
                            onPressed: () {
                              if (fileNameValidator(fileNametext) == null) {
                                _openFileExplorer();
                              }
                              // else{
                              //   fileNameValidator(fileNametext);
                              // }
                            },
                          ),
                          Spacer(),
                          ElevatedButton(
                            child: Text('Save Changes'),
                            onPressed: fileNameValidator(fileNametext) == null
                                ? () async {
                              setState(() {
                                loading = true;
                              });
                              var pathForPdf;
                              if (file != null) {
                                oldExt = file.extension.toLowerCase();
                                pathForPdf = file.path;
                              } else {
                                pathForPdf = pathPDF;
                              }
                              final finalOutput = await MedicalFilesApi.editDocumentsApi(
                                // filename: fileNametext+'.'+file.extension.toLowerCase(),
                                // path: file.path,
                                // extension: file.extension,
                                // doctype:_chosenType,
                                // // widget.docObject['document_type'],
                                // docmentId: widget.docObject['document_id'],
                                // iHLUserId:widget.iHLUserId
                                  filename: fileNametext + '.' + oldExt,
                                  path: pathForPdf,
                                  extension: oldExt,
                                  doctype: _chosenType,
                                  docmentId: widget.docObject['document_id'],
                                  iHLUserId: widget.iHLUserId);

                              edit = true;
                              // print(finalOutput['status']);
                              if (finalOutput['status'] == 'document edited successfully') {
                                //snackbar
                                snackBarForSuccess(
                                    snackName: 'Updated', fileName: shrinkExt);
                                await getFiles(widget.docObject['document_id']);
                                // await getFiles(widget.docObject['document_id']);
                                setState(() {
                                  loading = false;
                                });
                              } else {
                                snackBarForError(fileName: fileNametext, snackName: 'edit');
                                setState(() {
                                  loading = false;
                                });
                              }
                            }
                                : () {},
                          ),
                          Spacer(),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            body: SfPdfViewer.file(File(pathPDF))),
      );
    }
  }


  var filesData;
  var editedDocObject;

  getFiles(docId) async {
    final getUserFile = await _client.post(
      Uri.parse(API.iHLUrl + "/consult/view_user_medical_document"),
      headers: {
        'Content-Type': 'application/json',
        'ApiToken': '${API.headerr['ApiToken']}',
        'Token': '${API.headerr['Token']}',
      },
      body: jsonEncode(
        <String, String>{
          'ihl_user_id': "${widget.iHLUserId}", //"soTlvURs30uyrVP8osAZeQ",
        },
      ),
    );
    print('${getUserFile.statusCode}');
    if (getUserFile.statusCode == 200) {
      filesData = json.decode(getUserFile.body);
      // editedDocObject
      filesData.forEach((e) {
        if (e['document_id'] == docId) {
          // setState(() {
          editedDocObject = e;
          // widget.docObject=e;
          // });
        }
      });
      if (editedDocObject['document_link']
          .substring(editedDocObject['document_link'].lastIndexOf(".") + 1) ==
          'pdf') {
        widget.link = editedDocObject['document_link'];
        await createFileOfPdfUrl(obj: editedDocObject).then((f) {
          setState(() {
            pathPDF = f.path;
            print(pathPDF);
            // loading = false;
            type = 'pdf';
          });
        });
      } else if (editedDocObject['document_link']
          .substring(editedDocObject['document_link'].lastIndexOf(".") + 1) ==
          'jpg' ||
          editedDocObject['document_link']
              .substring(editedDocObject['document_link'].lastIndexOf(".") + 1) ==
              'png') {
        widget.link = editedDocObject['document_link'];
        widget.docObject = editedDocObject;

        setState(() {
          // loading = false;
          type = 'image';
          filename = editedDocObject['document_link']
              .substring(editedDocObject['document_link'].lastIndexOf("/") + 1);
          filenameFieldText = editedDocObject['document_name'].toString().replaceAll('.jpg', '');
          filenameFieldText = filenameFieldText.toString().replaceAll('.png', '');
          filenameFieldText = filenameFieldText.toString().replaceAll('.jpeg', '');
          fileNameController.text = filenameFieldText ?? 'loading...';
          fileNametext = filenameFieldText;
          _chosenType = editedDocObject['document_type'];
        });
      } else {
        setState(() {
          type = 'format';
        });
      }
      setState(() {
        loading = false;
      });
    } else {
      print(getUserFile.body);
    }
  }

  Widget saveButton() {
    return ButtonTheme(
      minWidth: 290.0,
      height: 50.0,
      child: IgnorePointer(
        ignoring: loading,
        child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: AppColors.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.0),
              ),
            ),
            child: loading
                ? new CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            )
                : Text("Confirm",
                style: TextStyle(
                  fontSize: 18,
                )),
            onPressed: () {
              //
            }),
      ),
    );
  }
}
