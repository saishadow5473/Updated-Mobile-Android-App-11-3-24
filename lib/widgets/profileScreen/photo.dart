import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_exif_rotation/flutter_exif_rotation.dart';
import 'package:get/get.dart';
import 'package:ihl/constants/spKeys.dart';
import 'package:ihl/constants/vitalUI.dart';
import 'package:ihl/models/checkInternet.dart';
import 'package:ihl/new_design/app/utils/localStorageKeys.dart';
import 'package:ihl/repositories/api_repository.dart';
import 'package:ihl/repositories/getuserData.dart';
import 'package:ihl/utils/SpUtil.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/utils/imageutils.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../new_design/data/providers/network/api_provider.dart';
import '../../new_design/data/providers/network/apis/splashScreenApis/splash_screen_apis.dart';
import '../../new_design/presentation/pages/profile/profile_screen.dart';
import '../../new_design/presentation/pages/profile/updatePhoto.dart';

// ignore: must_be_immutable
class ProfilePhoto extends StatefulWidget {
  bool update;
  ProfilePhoto({this.update});
  @override
  _ProfilePhotoState createState() => _ProfilePhotoState();
}

class _ProfilePhotoState extends State<ProfilePhoto> {
  bool loading = true;
  Image photo = maleAvatar;
  final Apirepository _apirepository = Apirepository();
  GetData _update = GetData();

  upload(File file, BuildContext context) {
    if (file == null) {
      return;
    }
    if (this.mounted) {
      setState(() {
        loading = true;
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.amber,
      content: Text('Uploading profile image'),
    ));
    String toUpload = base64String(file.readAsBytesSync());
    _apirepository.profileImageUpload(toUpload).then((value) {
      if (value.toString() == 'true') {
        _update.uptoUserInfoDate().then((val) async {
          if (val == true) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              backgroundColor: Colors.green,
              content: Text('Successfully uploaded profile image'),
            ));
            var response1 = await SplashScreenApiCalls().loginApi();
            if (response1 != null) {
              var b64Image = response1['User']["photo"] ?? AvatarImage.profilBase;

              if (b64Image != null) {
                SpUtil.putString(LSKeys.imageMemory, b64Image);
              }
            }

            if (this.mounted) {
              setState(() {
                loading = false;
                // Get.offAll(HomeScreen(introDone: true), transition: Transition.size);
                Get.to(Profile());
                photo = imageFromBase64String(toUpload);
                PhotoChangeNotifier.photo.value = toUpload;
              });
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              backgroundColor: Colors.red,
              content: Text('Failed to upload image'),
            ));
            if (this.mounted) {
              setState(() {
                loading = false;
              });
            }
          }
        });
      } else {
        if (this.mounted) {
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
      if (this.mounted) {
        setState(() {
          loading = false;
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
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
    var isAllowed = await permission.request().isGranted;

    if (isAllowed) {
      getIMG(source: ImageSource.gallery, context: cont);
      Navigator.of(context).pop();
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

  Future<void> _cup({BuildContext cont}) async {
    bool connection = await checkInternet();
    if (connection == false) {
      SnackBar snackBar = SnackBar(
        content:
            Text('Failed to connect to internet, Cannot change profile picture without internet'),
        backgroundColor: Colors.amber,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }

    return showCupertinoModalPopup(
      context: cont,
      builder: (context) => CupertinoActionSheet(
        title: Text('Upload profile photo'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: AppColors.primaryAccentColor,
                  padding: EdgeInsets.all(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
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
                  padding: EdgeInsets.all(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
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
              padding: EdgeInsets.all(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
      ).then((value) {
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
    var data = prefs.get(SPKeys.userData);
    data = data == null || data == '' ? '{"User":{}}' : data;
    var res = jsonDecode(data);
    if (res['User']['hasPhoto'] == true && res['User']['photo'] != null) {
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
    if (this.mounted) {
      this.setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  void didUpdateWidget(ProfilePhoto oldWidget) {
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
          CircleAvatar(
            backgroundColor: Color(0xfff4f6fa),
            radius: 75,
            child: loading ? CircularProgressIndicator() : null,
            backgroundImage: loading ? null : photo.image,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: CircleAvatar(
              child: Icon(Icons.photo_camera),
              backgroundColor: Color(0xfff4f6fa),
              radius: 20,
            ),
          ),
        ],
      ),
    );
  }
}

// ignore: must_be_immutable
class DrawerProfilePhoto extends StatefulWidget {
  bool update;
  DrawerProfilePhoto({this.update});
  @override
  _DrawerProfilePhotoState createState() => _DrawerProfilePhotoState();
}

class _DrawerProfilePhotoState extends State<DrawerProfilePhoto> {
  bool loading = true;
  Image photo = maleAvatar;
  final Apirepository _apirepository = Apirepository();
  GetData _update = GetData();

  upload(File file, BuildContext context) {
    if (file == null) {
      return;
    }
    if (this.mounted) {
      setState(() {
        loading = true;
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.amber,
      content: Text('Uploading profile image'),
    ));
    String toUpload = base64String(file.readAsBytesSync());
    _apirepository.profileImageUpload(toUpload).then((value) {
      if (value.toString() == 'true') {
        _update.uptoUserInfoDate().then((val) {
          if (val == true) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              backgroundColor: Colors.green,
              content: Text('Successfully uploaded profile image'),
            ));

            if (this.mounted) {
              setState(() {
                loading = false;
                photo = imageFromBase64String(toUpload);
              });
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              backgroundColor: Colors.red,
              content: Text('Failed to upload image'),
            ));
            if (this.mounted) {
              setState(() {
                loading = false;
              });
            }
          }
        });
      } else {
        if (this.mounted) {
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
      if (this.mounted) {
        setState(() {
          loading = false;
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
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

  void onGallery(BuildContext cont) async {
    var permission = Platform.isAndroid ? Permission.storage : Permission.photos;
    if (await permission.request().isGranted) {
      getIMG(source: ImageSource.gallery, context: cont);
      Navigator.of(context).pop();
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
              style: TextButton.styleFrom(foregroundColor: Colors.white),
              onPressed: () async {
                await openAppSettings();
              },
              child: Text('Allow')));
    }
  }

  Future<void> _cup({BuildContext cont}) async {
    bool connection = await checkInternet();
    if (connection == false) {
      SnackBar snackBar = SnackBar(
        content:
            Text('Failed to connect to internet, Cannot change profile picture without internet'),
        backgroundColor: Colors.amber,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }

    return showCupertinoModalPopup(
      context: cont,
      builder: (context) => CupertinoActionSheet(
        title: Text('Upload profile photo'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: AppColors.primaryAccentColor,
                  padding: EdgeInsets.all(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
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
                  padding: EdgeInsets.all(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
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
              padding: EdgeInsets.all(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
      ]).then((value) {
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
    var data = prefs.get(SPKeys.userData);
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
    if (this.mounted) {
      this.setState(() {});
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
            backgroundColor: Color(0xfff4f6fa),
            radius: 30,
            child: loading ? CircularProgressIndicator() : null,
            backgroundImage: loading ? null : photo.image,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: CircleAvatar(
              child: Icon(Icons.photo_camera, size: 18),
              backgroundColor: Color(0xfff4f6fa),
              radius: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class MediumProfilePhoto extends StatefulWidget {
  bool update;
  MediumProfilePhoto({this.update});
  @override
  _MediumProfilePhotoState createState() => _MediumProfilePhotoState();
}

class _MediumProfilePhotoState extends State<MediumProfilePhoto> {
  bool loading = true;
  Image photo = maleAvatar;
  final Apirepository _apirepository = Apirepository();
  GetData _update = GetData();

  upload(File file, BuildContext context) {
    if (file == null) {
      return;
    }
    if (this.mounted) {
      setState(() {
        loading = true;
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.amber,
      content: Text('Uploading profile image'),
    ));
    String toUpload = base64String(file.readAsBytesSync());
    _apirepository.profileImageUpload(toUpload).then((value) {
      if (value.toString() == 'true') {
        _update.uptoUserInfoDate().then((val) {
          if (val == true) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              backgroundColor: Colors.green,
              content: Text('Successfully uploaded profile image'),
            ));
            if (this.mounted) {
              setState(() {
                loading = false;
                photo = imageFromBase64String(toUpload);
              });
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              backgroundColor: Colors.red,
              content: Text('Failed to upload image'),
            ));
            if (this.mounted) {
              setState(() {
                loading = false;
              });
            }
          }
        });
      } else {
        if (this.mounted) {
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
      if (this.mounted) {
        setState(() {
          loading = false;
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
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

  void onGallery(BuildContext cont) async {
    var permission = Platform.isAndroid ? Permission.storage : Permission.photos;
    if (await permission.request().isGranted) {
      getIMG(source: ImageSource.gallery, context: cont);
      Navigator.of(context).pop();
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
              style: TextButton.styleFrom(foregroundColor: Colors.white),
              onPressed: () async {
                await openAppSettings();
              },
              child: Text('Allow')));
    }
  }

  Future<void> _cup({BuildContext cont}) async {
    bool connection = await checkInternet();
    if (connection == false) {
      SnackBar snackBar = SnackBar(
        content:
            Text('Failed to connect to internet, Cannot change profile picture without internet'),
        backgroundColor: Colors.amber,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }

    return showCupertinoModalPopup(
      context: cont,
      builder: (context) => CupertinoActionSheet(
        title: Text('Upload profile photo'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: AppColors.primaryAccentColor,
                  padding: EdgeInsets.all(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
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
                  padding: EdgeInsets.all(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
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
              padding: EdgeInsets.all(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
      ]).then((value) {
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
    var data = prefs.get(SPKeys.userData);
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
    if (this.mounted) {
      this.setState(() {});
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
            child: loading ? CircularProgressIndicator() : null,
            backgroundImage: loading ? null : photo.image,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: CircleAvatar(
              child: Icon(Icons.photo_camera, size: 18),
              backgroundColor: Color(0xfff4f6fa),
              radius: 14,
            ),
          ),
        ],
      ),
    );
  }
}
