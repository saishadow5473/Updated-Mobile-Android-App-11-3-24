import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_exif_rotation/flutter_exif_rotation.dart';
import 'package:get/get.dart';
import '../../../../constants/spKeys.dart';
import '../../../../constants/vitalUI.dart';
import '../../../../models/checkInternet.dart';
import '../../../app/utils/localStorageKeys.dart';
import 'myprofile.dart';
import '../../../../repositories/api_repository.dart';
import '../../../../repositories/getuserData.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/imageutils.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../../../utils/SpUtil.dart';
import '../../../../views/dietDashboard/edit_profile_screen.dart';

// ignore: must_be_immutable
class UpdatePhoto extends StatefulWidget {
  bool update;
  UpdatePhoto({Key key, this.update}) : super(key: key);
  @override
  _UpdatePhotoState createState() => _UpdatePhotoState();
}

class _UpdatePhotoState extends State<UpdatePhoto> {
  bool loading = true;
  Image photo = maleAvatar;
  final Apirepository _apirepository = Apirepository();
  final GetData _update = GetData();

  upload(File file, BuildContext context) {
    if (file == null) {
      return;
    }
    if (mounted) {
      setState(() {
        loading = true;
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      backgroundColor: Colors.amber,
      content: Text('Uploading profile image'),
    ));
    String toUpload = base64String(file.readAsBytesSync());
    _apirepository.profileImageUpload(toUpload).then((value) {
      if (value.toString() == 'true') {
        _update.uptoUserInfoDate().then((bool val) {
          if (val == true) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              backgroundColor: Colors.green,
              content: Text('Successfully uploaded profile image'),
            ));
            if (mounted) {
              setState(() {
                loading = false;
                photo = imageFromBase64String(toUpload);
                PhotoChangeNotifier.photo.value = toUpload;
              });
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              backgroundColor: Colors.red,
              content: Text('Failed to upload image'),
            ));
            if (mounted) {
              setState(() {
                loading = false;
              });
            }
          }
        });
      } else {
        if (mounted) {
          setState(() {
            loading = false;
          });
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.red,
          content: Text('$value'),
        ));
      }
    }).catchError((error) {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.red,
        content: Text('Failed to upload image'),
      ));
    });
  }

  void onCamera(BuildContext cont) async {
    if (await Permission.camera.request().isGranted) {
      getIMG(source: ImageSource.camera, context: cont);
      Navigator.of(context).pop();
    } else if (await Permission.camera.request().isDenied) {
      await Permission.camera.request();
      Get.snackbar('Camera Access Denied', 'Allow Camera permission to continue',
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
      Get.snackbar('Camera Access Denied', 'Allow Camera permission to continue',
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

  void onGallery(BuildContext cont) async {
    Permission permission = Permission.photos;
    if (Platform.isAndroid) {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      print(androidInfo.version.release);
      print(int.parse(androidInfo.version.release) <= 12);
      if (int.parse(androidInfo.version.release) <= 12) {
        permission = Permission.storage;
      }
    }
    print(permission);
    bool isAllowed = await permission.request().isGranted;
    print(isAllowed);
    if (await permission.request().isGranted) {
      getIMG(source: ImageSource.gallery, context: cont);
      Navigator.of(context).pop();
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

  Future<void> _cup({BuildContext cont}) async {
    bool connection = await checkInternet();
    if (connection == false) {
      SnackBar snackBar = const SnackBar(
        content:
            Text('Failed to connect to internet, Cannot change profile picture without internet'),
        backgroundColor: Colors.amber,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }

    return showCupertinoModalPopup(
      context: cont,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text('Upload profile photo'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: AppColors.primaryAccentColor,
                  padding: const EdgeInsets.all(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: const [
                    Icon(Icons.photo_camera),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      'Open Camera',
                      textScaleFactor: 1.5,
                    ),
                  ],
                ),
                onPressed: () {
                  onCamera(cont);
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: AppColors.primaryAccentColor,
                  padding: const EdgeInsets.all(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: const [
                    Icon(Icons.photo),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      'Open Gallery',
                      textScaleFactor: 1.5,
                    ),
                  ],
                ),
                onPressed: () {
                  onGallery(cont);
                },
              ),
            ),
          ),
        ],
        cancelButton: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.red,
              padding: const EdgeInsets.all(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  'Cancel',
                  textScaleFactor: 1.5,
                ),
              ],
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
      ),
    );
  }

  // ignore: missing_return
  Future<File> _pickImage({ImageSource source, BuildContext context}) async {
    final PickedFile picked = await ImagePicker().getImage(
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

  Future<File> getIMG({ImageSource source, BuildContext context}) async {
    File fromPickImage = await _pickImage(context: context, source: source);
    if (fromPickImage != null) {
      await crop(fromPickImage);
    } else {
      loading = false;
    }
  }

  Future crop(File selectedfile) async {
    try {
      await ImageCropper().cropImage(
        sourcePath: selectedfile.path,
        uiSettings: [
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
        ],
      ).then((CroppedFile value) {
        if (value != null) {
          upload(File(value.path), context);
        } else {
          loading = false;
        }
      });
    } catch (e) {
      return selectedfile;
    }
  }

  Future<void> getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Object data = prefs.get(SPKeys.userData);
    data = data == null || data == '' ? '{"User":{}}' : data;
    var res = jsonDecode(data);
    if (res['User']['hasPhoto'] == true && res['User']['photo'] != null) {
      photo = imageFromBase64String(res['User']['photo']);
      PhotoChangeNotifier.photo.value = res['User']['photo'];
      PhotoChangeNotifier.photo.notifyListeners();
    } else {
      if (res['User']['gender'] == 'm') {
        photo = maleAvatar;
      } else if (res['User']['gender'] == 'f') {
        photo = femaleAvatar;
      } else {
        photo = defAvatar;
      }
    }
    loading = false;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  void didUpdateWidget(UpdatePhoto oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.update == true) {
      getData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        _cup(cont: context);
      },
      child: Stack(
        children: [
          SizedBox(
            height: 18.h,
            child: Center(
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: () {
                      _cup(cont: context);
                    },
                    child: Container(
                      height: 22.h,
                      width: 28.w,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              fit: BoxFit.cover,
                              image: loading
                                  ? const NetworkImage(
                                      'https://th.bing.com/th/id/R.b4540f74398560af0e659238046e33a1?rik=si%2btArRvvTcfVg&riu=http%3a%2f%2fwww.solidbackgrounds.com%2fimages%2f1280x1024%2f1280x1024-light-gray-solid-color-background.jpg&ehk=FUNd9SgkDZVH6OXUIvfUIWLwcBIvwcJjnYomAJc4VKo%3d&risl=&pid=ImgRaw&r=0')
                                  : photo.image)),
                    ),
                  ),
                  Positioned(
                      bottom: 1.h,
                      right: 0,
                      child: GestureDetector(
                        onTap: () {
                          _cup(cont: context);
                        },
                        child: Container(
                          height: 40,
                          width: 40,
                          decoration:
                              const BoxDecoration(color: Color(0xffffffff), shape: BoxShape.circle),
                          child: const Icon(Icons.edit),
                        ),
                      ))
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ignore: must_be_immutable
class DrawerUpdatePhoto extends StatefulWidget {
  bool update;
  DrawerUpdatePhoto({Key key, this.update}) : super(key: key);
  @override
  _DrawerUpdatePhotoState createState() => _DrawerUpdatePhotoState();
}

class _DrawerUpdatePhotoState extends State<DrawerUpdatePhoto> {
  bool loading = true;
  Image photo = maleAvatar;
  final Apirepository _apirepository = Apirepository();
  final GetData _update = GetData();

  upload(File file, BuildContext context) {
    if (file == null) {
      return;
    }
    if (mounted) {
      setState(() {
        loading = true;
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      backgroundColor: Colors.amber,
      content: Text('Uploading profile image'),
    ));
    String toUpload = base64String(file.readAsBytesSync());
    _apirepository.profileImageUpload(toUpload).then((value) {
      if (value.toString() == 'true') {
        _update.uptoUserInfoDate().then((bool val) {
          if (val == true) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              backgroundColor: Colors.green,
              content: Text('Successfully uploaded profile image'),
            ));
            if (mounted) {
              setState(() {
                loading = false;

                photo = imageFromBase64String(toUpload);
                PhotoChangeNotifier.photo.value = toUpload;
              });
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              backgroundColor: Colors.red,
              content: Text('Failed to upload image'),
            ));
            if (mounted) {
              setState(() {
                loading = false;
              });
            }
          }
        });
      } else {
        if (mounted) {
          setState(() {
            loading = false;
          });
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.red,
          content: Text('$value'),
        ));
      }
    }).catchError((error) {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.red,
        content: Text('Failed to upload image'),
      ));
    });
  }

  void onCamera(BuildContext cont) async {
    if (await Permission.camera.request().isGranted) {
      getIMG(source: ImageSource.camera, context: cont);
      Navigator.of(context).pop();
    } else if (await Permission.camera.request().isDenied) {
      await Permission.camera.request();
      Get.snackbar('Camera Access Denied', 'Allow Camera permission to continue',
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
      Get.snackbar('Camera Access Denied', 'Allow Camera permission to continue',
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

  void onGallery(BuildContext cont) async {
    Permission permission = Permission.photos;
    if (Platform.isAndroid) {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      print(androidInfo.version.release);
      print(int.parse(androidInfo.version.release) <= 12);
      if (int.parse(androidInfo.version.release) <= 12) {
        permission = Permission.storage;
      }
    }
    print(permission);
    bool isAllowed = await permission.request().isGranted;
    print(isAllowed);
    if (await permission.request().isGranted) {
      getIMG(source: ImageSource.gallery, context: cont);
      Navigator.of(context).pop();
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
              style: TextButton.styleFrom(foregroundColor: Colors.white),
              onPressed: () async {
                await openAppSettings();
              },
              child: const Text('Allow')));
    }
  }

  Future<void> _cup({BuildContext cont}) async {
    bool connection = await checkInternet();
    if (connection == false) {
      SnackBar snackBar = const SnackBar(
        content:
            Text('Failed to connect to internet, Cannot change profile picture without internet'),
        backgroundColor: Colors.amber,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }

    return showCupertinoModalPopup(
      context: cont,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text('Upload profile photo'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: AppColors.primaryAccentColor,
                  padding: const EdgeInsets.all(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: const [
                    Icon(Icons.photo_camera),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      'Open Camera',
                      textScaleFactor: 1.5,
                    ),
                  ],
                ),
                onPressed: () {
                  onCamera(cont);
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: AppColors.primaryAccentColor,
                  padding: const EdgeInsets.all(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: const [
                    Icon(Icons.photo),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      'Open Gallery',
                      textScaleFactor: 1.5,
                    ),
                  ],
                ),
                onPressed: () {
                  onGallery(cont);
                },
              ),
            ),
          ),
        ],
        cancelButton: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.red,
              padding: const EdgeInsets.all(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  'Cancel',
                  textScaleFactor: 1.5,
                ),
              ],
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
      ),
    );
  }

  // ignore: missing_return
  Future<File> _pickImage({ImageSource source, BuildContext context}) async {
    final PickedFile picked = await ImagePicker().getImage(
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

  Future<File> getIMG({ImageSource source, BuildContext context}) async {
    File fromPickImage = await _pickImage(context: context, source: source);
    if (fromPickImage != null) {
      await crop(fromPickImage);
    } else {
      loading = false;
    }
  }

  Future crop(File selectedfile) async {
    try {
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
      ]).then((CroppedFile value) {
        if (value != null) {
          upload(File(value.path), context);
        } else {
          loading = false;
        }
      });
    } catch (e) {
      return selectedfile;
    }
  }

  Future<void> getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Object data = prefs.get(SPKeys.userData);
    data = data == null || data == '' ? '{"User":{}}' : data;
    var res = jsonDecode(data);
    if (res['User']['hasPhoto'] == true) {
      photo = imageFromBase64String(res['User']['photo']);
    } else {
      if (res['User']['gender'] == 'm') {
        photo = maleAvatar;
      } else if (res['User']['gender'] == 'f') {
        photo = femaleAvatar;
      } else {
        photo = defAvatar;
      }
    }
    loading = false;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        _cup(cont: context);
      },
      child: Stack(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xfff4f6fa),
            radius: 30,
            backgroundImage: loading ? null : photo.image,
            child: loading ? CircularProgressIndicator() : null,
          ),
          const Positioned(
            bottom: 0,
            right: 0,
            child: CircleAvatar(
              backgroundColor: Color(0xfff4f6fa),
              radius: 12,
              child: Icon(Icons.photo_camera, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}

class MediumUpdatePhoto extends StatefulWidget {
  bool update;
  MediumUpdatePhoto({Key key, this.update}) : super(key: key);
  @override
  _MediumUpdatePhotoState createState() => _MediumUpdatePhotoState();
}

class _MediumUpdatePhotoState extends State<MediumUpdatePhoto> {
  bool loading = true;
  Image photo = maleAvatar;
  final Apirepository _apirepository = Apirepository();
  final GetData _update = GetData();

  upload(File file, BuildContext context) {
    if (file == null) {
      return;
    }
    if (mounted) {
      setState(() {
        loading = true;
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      backgroundColor: Colors.amber,
      content: Text('Uploading profile image'),
    ));
    String toUpload = base64String(file.readAsBytesSync());
    _apirepository.profileImageUpload(toUpload).then((value) {
      if (value.toString() == 'true') {
        _update.uptoUserInfoDate().then((bool val) {
          if (val == true) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              backgroundColor: Colors.green,
              content: Text('Successfully uploaded profile image'),
            ));
            if (mounted) {
              setState(() {
                loading = false;
                photo = imageFromBase64String(toUpload);
              });
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              backgroundColor: Colors.red,
              content: Text('Failed to upload image'),
            ));
            if (mounted) {
              setState(() {
                loading = false;
              });
            }
          }
        });
      } else {
        if (mounted) {
          setState(() {
            loading = false;
          });
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.red,
          content: Text('$value'),
        ));
      }
    }).catchError((error) {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.red,
        content: Text('Failed to upload image'),
      ));
    });
  }

  void onCamera(BuildContext cont) async {
    if (await Permission.camera.request().isGranted) {
      getIMG(source: ImageSource.camera, context: cont);
      Navigator.of(context).pop();
    } else if (await Permission.camera.request().isDenied) {
      await Permission.camera.request();
      Get.snackbar('Camera Access Denied', 'Allow Camera permission to continue',
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
      Get.snackbar('Camera Access Denied', 'Allow Camera permission to continue',
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

  void onGallery(BuildContext cont) async {
    Permission permission = Permission.photos;
    if (Platform.isAndroid) {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      print(androidInfo.version.release);
      print(int.parse(androidInfo.version.release) <= 12);
      if (int.parse(androidInfo.version.release) <= 12) {
        permission = Permission.storage;
      }
    }
    print(permission);
    bool isAllowed = await permission.request().isGranted;
    print(isAllowed);
    if (await permission.request().isGranted) {
      getIMG(source: ImageSource.gallery, context: cont);
      Navigator.of(context).pop();
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
              style: TextButton.styleFrom(foregroundColor: Colors.white),
              onPressed: () async {
                await openAppSettings();
              },
              child: const Text('Allow')));
    }
  }

  Future<void> _cup({BuildContext cont}) async {
    bool connection = await checkInternet();
    if (connection == false) {
      SnackBar snackBar = const SnackBar(
        content:
            Text('Failed to connect to internet, Cannot change profile picture without internet'),
        backgroundColor: Colors.amber,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }

    return showCupertinoModalPopup(
      context: cont,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text('Upload profile photo'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: AppColors.primaryAccentColor,
                  padding: const EdgeInsets.all(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: const [
                    Icon(Icons.photo_camera),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      'Open Camera',
                      textScaleFactor: 1.5,
                    ),
                  ],
                ),
                onPressed: () {
                  onCamera(cont);
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: AppColors.primaryAccentColor,
                  padding: const EdgeInsets.all(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: const [
                    Icon(Icons.photo),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      'Open Gallery',
                      textScaleFactor: 1.5,
                    ),
                  ],
                ),
                onPressed: () {
                  onGallery(cont);
                },
              ),
            ),
          ),
        ],
        cancelButton: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.red,
              padding: const EdgeInsets.all(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  'Cancel',
                  textScaleFactor: 1.5,
                ),
              ],
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
      ),
    );
  }

  // ignore: missing_return
  Future<File> _pickImage({ImageSource source, BuildContext context}) async {
    final PickedFile picked = await ImagePicker().getImage(
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

  Future<File> getIMG({ImageSource source, BuildContext context}) async {
    File fromPickImage = await _pickImage(context: context, source: source);
    if (fromPickImage != null) {
      await crop(fromPickImage);
    } else {
      loading = false;
    }
  }

  Future crop(File selectedfile) async {
    try {
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
      ]).then((CroppedFile value) {
        if (value != null) {
          upload(File(value.path), context);
        } else {
          loading = false;
        }
      });
    } catch (e) {
      return selectedfile;
    }
  }

  Future<void> getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Object data = prefs.get(SPKeys.userData);
    data = data == null || data == '' ? '{"User":{}}' : data;
    var res = jsonDecode(data);
    if (res['User']['hasPhoto'] == true) {
      photo = imageFromBase64String(res['User']['photo']);
    } else {
      if (res['User']['gender'] == 'm') {
        photo = maleAvatar;
      } else if (res['User']['gender'] == 'f') {
        photo = femaleAvatar;
      } else {
        photo = defAvatar;
      }
    }
    loading = false;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        _cup(cont: context);
      },
      child: Stack(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primaryColor,
            radius: 45,
            backgroundImage: loading ? null : photo.image,
            child: loading ? CircularProgressIndicator() : null,
          ),
          const Positioned(
            bottom: 0,
            right: 0,
            child: CircleAvatar(
              backgroundColor: Color(0xfff4f6fa),
              radius: 14,
              child: Icon(Icons.photo_camera, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}

class PhotoChangeNotifier {
  static ValueNotifier<String> photo =
      ValueNotifier<String>(SpUtil.getString(LSKeys.imageMemory) ?? '');
}
