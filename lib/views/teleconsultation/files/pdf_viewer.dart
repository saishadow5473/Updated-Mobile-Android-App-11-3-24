import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ihl/constants/api.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'file_edit_view.dart';
import 'file_resuable_snackbar.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
// import 'package:pdf/widgets.dart';

class PdfView extends StatefulWidget {
  PdfView(this.link, this.docObject, this.iHLUserId, {this.showExtraButton});

  var link;
  final docObject;
  final iHLUserId;
  var showExtraButton;

  @override
  _PdfViewState createState() => new _PdfViewState();
}

class _PdfViewState extends State<PdfView> {
  http.Client _client = http.Client(); //3gb
  bool refresh = false;
  String pathPDF = "";
  bool loading = true;
  String type = 'pdf';
  FilePickerResult result;

  // bool fileSelected = false;
  PlatformFile file;

  @override
  void initState() {
    if (widget.showExtraButton == null) {
      widget.showExtraButton = true;
    }
    super.initState();
    if (widget.link.substring(widget.link.lastIndexOf(".") + 1) == 'pdf') {
      createFileOfPdfUrl().then((f) {
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
      setState(() {
        loading = false;
        type = 'image';
        filename = widget.link.substring(widget.link.lastIndexOf("/") + 1);
      });
    } else {
      setState(() {
        type = 'format';
      });
      // Navigator.push(
      //     context,
      //     MaterialPageRoute(builder: (context) => ShowImage('Format')));
    }
  }

  bool edit = false;
  bool delete = false;
  var filename;

  Future<File> createFileOfPdfUrl() async {
    final url = widget.link; //"http://africau.edu/images/default/sample.pdf";
    filename = url.substring(url.lastIndexOf("/") + 1);
    var request = await HttpClient().getUrl(Uri.parse(url));
    var response = await request.close();
    var bytes = await consolidateHttpClientResponseBytes(response);
    String dir = (await getApplicationDocumentsDirectory()).path;
    File file = new File('$dir/$filename');
    await file.writeAsBytes(bytes);
    // setState(() {
    //
    // });
    return file;
  }

  Future<void> _openFileExplorer() async {
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
        loading = true;
      });
      final finalOutput = await MedicalFilesApi.editDocumentsApi(
          filename: file.name,
          path: file.path,
          extension: file.extension,
          doctype: widget.docObject['document_type'],
          docmentId: widget.docObject['document_id'],
          iHLUserId: widget.iHLUserId);
      edit = true;
      print(finalOutput['status']);
      if (finalOutput['status'] == 'document edited successfully') {
        //snackbar
        snackBarForSuccess(snackName: 'Updated', fileName: filename);
        getFiles(widget.docObject['document_id']);
      } else {
        snackBarForError(fileName: filename, snackName: 'edit');
        setState(() {
          loading = false;
        });
      }
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

  Future<bool> _willPopCallback() {
    if (edit || delete) {
      refresh = true;
    }
    Navigator.of(context).pop(refresh);
  }

  void _shareFiles(String link) async {
    final response = await http.get(Uri.parse(link));
    final bytes = response.bodyBytes;
    final temp = await getTemporaryDirectory();
    final path = '${temp.path}/$filename';
    File(path).writeAsBytesSync(bytes);
    await Share.shareFiles([path], text: filename);
    if (Platform.isIOS) {
      if (await canLaunch(link)) {
        await Share.share(link);
      } else {
        print('Could not launch Teams.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!loading) {
      if (type == 'image') {
        return WillPopScope(
          onWillPop: _willPopCallback,
          child: Scaffold(
            appBar: AppBar(
              iconTheme: IconThemeData(color: Colors.white),
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios),
                onPressed: _willPopCallback,
                color: Colors.white,
              ),
              title: Text(
                '${widget.docObject['document_name'] ?? 'Image'}',
                style: TextStyle(color: Colors.white),
              ),
              actions: widget.showExtraButton
                  ? <Widget>[
                      IconButton(
                          onPressed: () => _shareFiles(widget.link), icon: const Icon(Icons.share)),
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () async {
                          // _openFileExplorer();
                          edit = true;
                          final returnData = await Get.to(FileEditView(
                            widget.link,
                            widget.docObject,
                            widget.iHLUserId,
                          ));
                          if (returnData) {
                            _willPopCallback();
                          }
                        },
                      ),
                      IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () async {
                            AwesomeDialog(
                                    context: context,
                                    animType: AnimType.TOPSLIDE,
                                    headerAnimationLoop: true,
                                    dialogType: DialogType.WARNING,
                                    dismissOnTouchOutside: true,
                                    title: 'Confirm ?',
                                    desc: 'this action will delete your report',
                                    btnOkOnPress: () async {
                                      setState(() {
                                        loading = true;
                                      });
                                      delete = true;
                                      final output = await MedicalFilesApi.deleteFileApi(
                                          widget.docObject['document_id'],
                                          widget.docObject['document_name'],
                                          widget.iHLUserId);

                                      if (output['status'] == 'document deleted successfully') {
                                        //snackbar
                                        // Get.snackbar('Deleted!', '${camelize(filename)} deleted successfully.',
                                        //     icon: Padding(
                                        //         padding: const EdgeInsets.all(8.0),
                                        //         child: Icon(Icons.check_circle, color: Colors.white)),
                                        //     margin: EdgeInsets.all(20).copyWith(bottom: 40),
                                        //     backgroundColor: AppColors.primaryAccentColor,
                                        //     colorText: Colors.white,
                                        //     duration: Duration(seconds: 5),
                                        //     snackPosition: SnackPosition.BOTTOM);
                                        setState(() {
                                          loading = false;
                                        });
                                        refresh = true;
                                        Navigator.pop(context, refresh);
                                        // getFiles();
                                      } else {
                                        setState(() {
                                          loading = false;
                                        });
                                        Get.snackbar('File not deleted',
                                            'Encountered some error while deleting. Please try again',
                                            icon: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child:
                                                  Icon(Icons.cancel_rounded, color: Colors.white),
                                            ),
                                            margin: EdgeInsets.all(20).copyWith(bottom: 40),
                                            backgroundColor: Colors.red,
                                            colorText: Colors.white,
                                            duration: Duration(seconds: 5),
                                            snackPosition: SnackPosition.BOTTOM);
                                      }

                                      // Get.back();
                                    },
                                    btnCancelOnPress: () {},
                                    btnCancelText: 'Go Back',
                                    btnOkText: 'Confirm',
                                    btnCancelColor: Colors.green,
                                    btnOkColor: Colors.red,
                                    // btnOkIcon: Icons.check_circle,
                                    // btnCancelIcon: Icons.check_circle,
                                    onDismissCallback: (_) {})
                                .show();
                          }),
                    ]
                  : [],
            ),
            body: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage('${widget.link}'),
                ),
              ),
            ),
          ),
        );
      } else if (type == 'format') {
        return Scaffold(
            body: Container(
          child: Center(
            child: Text('Format Not Showed'),
          ),
        ));
      } else {
        return WillPopScope(
          onWillPop: _willPopCallback,
          child: Scaffold(
              appBar: AppBar(
                title: Text(
                  '${widget.docObject['document_name'] ?? 'Docs'}',
                  style: TextStyle(color: Colors.white),
                ),
                iconTheme: IconThemeData(color: Colors.white),
                actions: widget.showExtraButton
                    ? <Widget>[
                        IconButton(
                            onPressed: () => _shareFiles(widget.link),
                            icon: const Icon(Icons.share)),
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () async {
                            // _openFileExplorer();
                            edit = true;
                            final returnData = await Get.to(FileEditView(
                              widget.link,
                              widget.docObject,
                              widget.iHLUserId,
                            ));
                            if (returnData) {
                              _willPopCallback();
                            }
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () async {
                            AwesomeDialog(
                                    context: context,
                                    animType: AnimType.TOPSLIDE,
                                    headerAnimationLoop: true,
                                    dialogType: DialogType.WARNING,
                                    dismissOnTouchOutside: true,
                                    title: 'Confirm ?',
                                    desc: 'this action will delete your report',
                                    btnOkOnPress: () async {
                                      setState(() {
                                        loading = true;
                                      });
                                      delete = true;
                                      final output = await MedicalFilesApi.deleteFileApi(
                                          widget.docObject['document_id'],
                                          widget.docObject['document_name'],
                                          widget.iHLUserId);

                                      if (output['status'] == 'document deleted successfully') {
                                        //snackbar
                                        // Get.snackbar('Deleted!', '${camelize(filename)} deleted successfully.',
                                        //     icon: Padding(
                                        //         padding: const EdgeInsets.all(8.0),
                                        //         child: Icon(Icons.check_circle, color: Colors.white)),
                                        //     margin: EdgeInsets.all(20).copyWith(bottom: 40),
                                        //     backgroundColor: AppColors.primaryAccentColor,
                                        //     colorText: Colors.white,
                                        //     duration: Duration(seconds: 5),
                                        //     snackPosition: SnackPosition.BOTTOM);
                                        setState(() {
                                          loading = false;
                                        });
                                        refresh = true;
                                        Navigator.pop(context, refresh);
                                        // getFiles();
                                      } else {
                                        setState(() {
                                          loading = false;
                                        });
                                        Get.snackbar('File not deleted',
                                            'Encountered some error while deleting. Please try again',
                                            icon: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child:
                                                  Icon(Icons.cancel_rounded, color: Colors.white),
                                            ),
                                            margin: EdgeInsets.all(20).copyWith(bottom: 40),
                                            backgroundColor: Colors.red,
                                            colorText: Colors.white,
                                            duration: Duration(seconds: 5),
                                            snackPosition: SnackPosition.BOTTOM);
                                      }

                                      // Get.back();
                                    },
                                    btnCancelOnPress: () {},
                                    btnCancelText: 'Go Back',
                                    btnOkText: 'Confirm',
                                    btnCancelColor: Colors.green,
                                    btnOkColor: Colors.red,
                                    // btnOkIcon: Icons.check_circle,
                                    // btnCancelIcon: Icons.check_circle,
                                    onDismissCallback: (_) {})
                                .show();
                          },
                        ),
                      ]
                    : [],
              ),
              body: SfPdfViewer.file(File(pathPDF))),
        );
      }
    }

    if (loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('loading...')),
        body: Center(child: CircularProgressIndicator()
            // RaisedButton(
            //   child: CircularProgressIndicator(),
            //   onPressed: () =>
            //       Navigator.push(
            //         context,
            //         MaterialPageRoute(builder: (context) => PDFScreen(pathPDF)),
            //       ),
            // ),
            ),
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
          editedDocObject = e;
        }
      });
      // setState(() {
      //   loading = false;
      // filesData;
      // });
      if (editedDocObject['document_link']
              .substring(editedDocObject['document_link'].lastIndexOf(".") + 1) ==
          'pdf') {
        widget.link = editedDocObject['document_link'];
        createFileOfPdfUrl().then((f) {
          setState(() {
            pathPDF = f.path;
            print(pathPDF);
            loading = false;
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
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(builder: (context) => ShowImage(widget.link)));
        setState(() {
          loading = false;
          type = 'image';
          filename = editedDocObject['document_link']
              .substring(editedDocObject['document_link'].lastIndexOf("/") + 1);
        });
      } else {
        setState(() {
          type = 'format';
        });
        // Navigator.push(
        //     context,
        //     MaterialPageRoute(builder: (context) => ShowImage('Format')));
      }
      print(getUserFile.body);
    } else {
      print(getUserFile.body);
    }
  }
}

// class PDFScreen extends StatelessWidget {
//   String pathPDF = "";
//   PDFScreen(this.pathPDF);
//
//   @override
//   Widget build(BuildContext context) {
//     return PDFViewerScaffold(
//         appBar: AppBar(
//           title: Text("Document"),
//           actions: <Widget>[
//             IconButton(
//               icon: Icon(Icons.share),
//               onPressed: () {},
//             ),
//           ],
//         ),
//         path: pathPDF);
//   }
// }
