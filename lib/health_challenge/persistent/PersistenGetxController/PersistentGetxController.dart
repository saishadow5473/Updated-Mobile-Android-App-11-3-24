import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ihl/Getx/controller/listOfChallengeContoller.dart';
import 'package:ihl/health_challenge/controllers/challenge_api.dart';
import 'package:ihl/health_challenge/models/challenge_detail.dart';
import 'package:ihl/health_challenge/models/enrolled_challenge.dart';
import 'package:ihl/health_challenge/models/group_details_model.dart';
import 'package:ihl/health_challenge/networks/network_calls.dart';
import 'package:ihl/health_challenge/persistent/models/persistent_screenshot_model.dart';
import 'package:ihl/health_challenge/persistent/views/persistnet_certificateScreen.dart';
import 'package:image/image.dart' as ui;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_watermark/image_watermark.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../constants/spKeys.dart';
import '../../../new_design/app/config/permission_config.dart';
import '../../../utils/app_colors.dart';
import '../../models/get_selfie_image_model.dart';
import '../../models/selfie_image_upload_model.dart';
import '../../views/certificate_detail.dart';
import '../../views/on_going_challenge.dart';
import '../views/persistent_onGoingScreen.dart';

class PersistentGetXController extends GetxController {
  final ListChallengeController _listChallengeController = Get.find();

  final picker = ImagePicker();
  String userUid = '';

  bool photoUploaded = false;
  bool selfiUploaded = false;
  EnrolledChallenge getxEnrollChallenge, updateEnrollChallenge;
  updateEnrolledChallenge(ListChallengeController controller) async {}
  imageSelection(
      {EnrolledChallenge enrollChallenge, isSelfi, ChallengeDetail challengeDetail}) async {
    getxEnrollChallenge = await ChallengeApi().getEnrollDetail(enrollChallenge.enrollmentId);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var k = jsonDecode(prefs.getString(SPKeys.jUserData));
    userUid = k["User"]["id"];
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.0),
        ),
        context: Get.context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Wrap(
              children: <Widget>[
                ListTile(
                    leading: const Icon(Icons.photo_library),
                    title: const Text('Photo Library'),
                    onTap: () {
                      _imgFromGallery(isSelfi, challengeDetail);
                      Get.back();
                    }),
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: const Text('Camera'),
                  onTap: () {
                    _imgFromCamera(isSelfi, challengeDetail);
                    Get.back();
                  },
                ),
              ],
            ),
          );
        });
  }

//for Image selection and Upload
  CroppedFile stepCroppedFile;
  File _image;
  bool imageSelected = false;
  String base64Image;

  _imgFromCamera(isSelfi, ChallengeDetail challengeDetail) async {
    bool _permissionStatus = await PermissionHandlerUtil.cameraPermission();
    if (_permissionStatus) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var data = prefs.get('data');
      final map = jsonDecode(data);
      dynamic iHLUserId = map["User"]["id"];
      if (await Permission.camera.isPermanentlyDenied || await Permission.camera.isDenied) {
        Get.defaultDialog(
            title: "",
            titlePadding: const EdgeInsets.all(0),
            content: Column(mainAxisSize: MainAxisSize.min, children: [
              const Text(
                "Allow Camera Access",
                style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w300),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                child: const Text("Turn on"),
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue,
                ),
                onPressed: () async {
                  await openAppSettings();
                  Get.back();
                },
              ),
            ]),
            backgroundColor: Colors.white,
            // titleStyle: TextStyle(color: Colors.black),
            // middleTextStyle: TextStyle(color: Colors.black),
            radius: 30);
      } else {
        final pickedFile = await picker.pickImage(source: ImageSource.camera);
        _image = File(pickedFile.path);
        stepCroppedFile = await ImageCropper().cropImage(
          sourcePath: _image.path,
          aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
          maxWidth: 512,
          maxHeight: 512,
          compressFormat: ImageCompressFormat.png,
          compressQuality: 100,
          uiSettings: [
            AndroidUiSettings(
              lockAspectRatio: isSelfi,
              activeControlsWidgetColor: AppColors.primaryAccentColor,
              toolbarTitle: 'Cropper',
              toolbarColor: AppColors.primaryAccentColor,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
            ),
            IOSUiSettings(title: 'Crop the Image', aspectRatioLockEnabled: true),
            WebUiSettings(
              context: Get.context,
            ),
          ],
        );
        if (!isSelfi) {
          File _cropedFile = File(stepCroppedFile.path);
          List<int> imageBytes = _cropedFile.readAsBytesSync();
          base64Image = base64.encode(imageBytes);
          imageSelected = true;
          if (getxEnrollChallenge.docStatus.toLowerCase() != "requested" &&
              getxEnrollChallenge.docStatus.toLowerCase() != "accepted") {
            _listChallengeController.enrolledChallenge();
            photoUploaded = await ChallengeApi().putScreenShotUploadPersistent(
                persistentUploadScreenShot: PersistentUploadScreenShot(
                    challengeid: getxEnrollChallenge.challengeId,
                    enrollId: getxEnrollChallenge.enrollmentId,
                    userId: userUid,
                    testimg: _cropedFile));
            update(['photoUpload']);
          }
        } else if (stepCroppedFile != null) {
          Get.defaultDialog(
            title: "Uploading",
            backgroundColor: Colors.lightBlue.shade50,
            content: const CircularProgressIndicator(),
            titlePadding: const EdgeInsets.only(top: 20, bottom: 10, right: 10, left: 10),
            titleStyle: TextStyle(letterSpacing: 1, color: Colors.blue.shade400, fontSize: 20),
            contentPadding: const EdgeInsets.only(top: 20, bottom: 10),
          );
          File file = await waterMarkGene(challengeDetail);

          selfiUploaded = await ChallengeApi().putUploadSelfie(
              selfieImgUpload: SelfieImgUpload(
                  challengeid: getxEnrollChallenge.challengeId,
                  enrollId: getxEnrollChallenge.enrollmentId,
                  userid: userUid,
                  selfieImage: file));

          stepCroppedFile = null;
          Get.back();
          if (selfiUploaded) {
            update(['photoUpload']);
            Get.defaultDialog(
              barrierDismissible: true,
              backgroundColor: Colors.lightBlue.shade50,
              title: "Uploded",
              titlePadding: const EdgeInsets.only(top: 20, bottom: 10, right: 10, left: 10),
              titleStyle: TextStyle(letterSpacing: 1, color: Colors.blue.shade400, fontSize: 20),
              contentPadding: const EdgeInsets.only(top: 20, bottom: 10),
              content: const Text("Uploded Succefully"),
            );
            ChallengeDetail _challengeDetail =
                await ChallengeApi().challengeDetail(challengeId: getxEnrollChallenge.challengeId);
            if (getxEnrollChallenge.selectedFitnessApp != "other_apps") {
              if (getxEnrollChallenge.userProgress == "progressing") {
                Get.back();
                Get.to(OnGoingChallenge(
                  challengeDetail: _challengeDetail,
                  navigatedNormal: false,
                  filteredList: getxEnrollChallenge,
                ));
              } else if (getxEnrollChallenge.userProgress == "completed") {
                if (getxEnrollChallenge.challengeMode != "individual") {
                  bool currentUserIsAdmin = false;
                  GroupDetailModel groupDetailModel;
                  String userid = iHLUserId;
                  await ChallengeApi()
                      .listofGroupUsers(groupId: getxEnrollChallenge.groupId)
                      .then((value) {
                    for (var i in value) {
                      if (i.userId == userid && i.role == "admin") {
                        currentUserIsAdmin = true;
                        break;
                      }
                    }
                  });
                  groupDetailModel = await ChallengeApi()
                      .challengeGroupDetail(groupID: getxEnrollChallenge.groupId);
                  Get.back();
                  Get.to(CertificateDetail(
                    challengeDetail: _challengeDetail,
                    enrolledChallenge: getxEnrollChallenge,
                    groupDetail: groupDetailModel,
                    currentUserIsAdmin: currentUserIsAdmin,
                    firstCopmlete: false,
                  ));
                } else {
                  Get.back();
                  Get.to(CertificateDetail(
                    challengeDetail: _challengeDetail,
                    enrolledChallenge: getxEnrollChallenge,
                    groupDetail: null,
                    currentUserIsAdmin: false,
                    firstCopmlete: false,
                  ));
                }
              } else {
                null;
              }
            } else {
              if (getxEnrollChallenge.docStatus == null ||
                  getxEnrollChallenge.docStatus.toLowerCase() == "requested" ||
                  getxEnrollChallenge.docStatus == "") {
                Get.back();
                Get.to(PersistentOnGoingScreen(
                  challengeStarted:
                      DateTime.now().isAfter(getxEnrollChallenge.challenge_start_time) ||
                          (DateFormat('MM-dd-yyyy')
                                  .format(getxEnrollChallenge.challenge_start_time)
                                  .toString() ==
                              "01-01-2000"),
                  enrolledChallenge: getxEnrollChallenge,
                  nrmlJoin: false,
                  challengeDetail: _challengeDetail,
                ));
              } else if (getxEnrollChallenge.userProgress == "completed") {
                Get.back();
                Get.to(PersistentCertificateScreen(
                  challengedetail: _challengeDetail,
                  enrolledChallenge: getxEnrollChallenge,
                  navNormal: false,
                  firstComplete: false,
                ));
              } else {
                null;
              }
            }
          } else {
            Get.defaultDialog(
                barrierDismissible: true,
                backgroundColor: Colors.lightBlue.shade50,
                titlePadding: const EdgeInsets.only(top: 20, bottom: 10, right: 10, left: 10),
                titleStyle: TextStyle(letterSpacing: 1, color: Colors.blue.shade400, fontSize: 20),
                contentPadding: const EdgeInsets.only(top: 20, bottom: 10),
                content: const Text("Image not Uploaded"));
            update(['photoUpload']);
          }
        } else {
          null;
        }
      }
    }
  }

  _imgFromGallery(isSelfi, ChallengeDetail challengeDetail) async {
    bool _permission = await PermissionHandlerUtil.mediaPermission();
    if (_permission) {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      _image = File(pickedFile.path);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var data = prefs.get('data');
      final map = jsonDecode(data);
      dynamic iHLUserId = map["User"]["id"];
      stepCroppedFile = await ImageCropper().cropImage(
        sourcePath: _image.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        maxWidth: 512,
        maxHeight: 512,
        compressFormat: ImageCompressFormat.png,
        compressQuality: 100,
        uiSettings: [
          AndroidUiSettings(
            lockAspectRatio: isSelfi,
            activeControlsWidgetColor: AppColors.primaryAccentColor,
            toolbarTitle: 'Cropper',
            toolbarColor: AppColors.primaryAccentColor,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
          ),
          IOSUiSettings(title: 'Crop the Image', aspectRatioLockEnabled: true),
          WebUiSettings(
            context: Get.context,
          ),
        ],
      );

      if (!isSelfi) {
        List<int> imageBytes = File(stepCroppedFile.path).readAsBytesSync();
        base64Image = base64.encode(imageBytes);
        imageSelected = true;
        if (getxEnrollChallenge.docStatus.toLowerCase() != "requested" &&
            getxEnrollChallenge.docStatus.toLowerCase() != "accepted") {
          _listChallengeController.enrolledChallenge();
          photoUploaded = await ChallengeApi().putScreenShotUploadPersistent(
              persistentUploadScreenShot: PersistentUploadScreenShot(
                  challengeid: getxEnrollChallenge.challengeId,
                  enrollId: getxEnrollChallenge.enrollmentId,
                  userId: userUid,
                  testimg: File(stepCroppedFile.path)));
          update(['photoUpload']);
        }
      } else if (stepCroppedFile != null) {
        Get.defaultDialog(
          title: "Uploading",
          backgroundColor: Colors.lightBlue.shade50,
          content: const CircularProgressIndicator(),
          titlePadding: const EdgeInsets.only(top: 20, bottom: 10, right: 10, left: 10),
          titleStyle: TextStyle(letterSpacing: 1, color: Colors.blue.shade400, fontSize: 20),
          contentPadding: const EdgeInsets.only(top: 20, bottom: 10),
        );
        File file = await waterMarkGene(challengeDetail);
        try {
          selfiUploaded = await ChallengeApi().putUploadSelfie(
              selfieImgUpload: SelfieImgUpload(
                  challengeid: getxEnrollChallenge.challengeId,
                  enrollId: getxEnrollChallenge.enrollmentId,
                  userid: userUid,
                  selfieImage: file));
          await getImageData(enroll_id: getxEnrollChallenge.enrollmentId);
        } catch (e) {
          debugPrint('Upload Error');
        }
        update(['photoUpload']);

        stepCroppedFile = null;
        Get.back();

        if (selfiUploaded) {
          Get.defaultDialog(
            barrierDismissible: true,
            backgroundColor: Colors.lightBlue.shade50,
            title: "Uploded",
            titlePadding: const EdgeInsets.only(top: 20, bottom: 10, right: 10, left: 10),
            titleStyle: TextStyle(letterSpacing: 1, color: Colors.blue.shade400, fontSize: 20),
            contentPadding: const EdgeInsets.only(top: 20, bottom: 10),
            content: const Text("Uploded Succefully"),
          );
          ChallengeDetail _challengeDetail =
              await ChallengeApi().challengeDetail(challengeId: getxEnrollChallenge.challengeId);
          await getImageData(enroll_id: getxEnrollChallenge.enrollmentId);
          update(['photoUpload']);

          if (getxEnrollChallenge.selectedFitnessApp != "other_apps") {
            if (getxEnrollChallenge.userProgress == "progressing") {
              if (getxEnrollChallenge.challengeMode == "individual") {
                Get.back();
                Get.to(OnGoingChallenge(
                  groupDetail: null,
                  challengeDetail: _challengeDetail,
                  navigatedNormal: false,
                  filteredList: getxEnrollChallenge,
                ));
              } else {
                GroupDetailModel _groupDetail =
                    await ChallengeApi().challengeGroupDetail(groupID: getxEnrollChallenge.groupId);
                Get.back();
                Get.to(OnGoingChallenge(
                  groupDetail: _groupDetail,
                  challengeDetail: _challengeDetail,
                  navigatedNormal: false,
                  filteredList: getxEnrollChallenge,
                ));
              }
            } else if (getxEnrollChallenge.userProgress == "completed") {
              if (getxEnrollChallenge.challengeMode != "individual") {
                bool currentUserIsAdmin = false;
                GroupDetailModel groupDetailModel;
                String userid = iHLUserId;
                await ChallengeApi()
                    .listofGroupUsers(groupId: getxEnrollChallenge.groupId)
                    .then((value) {
                  for (var i in value) {
                    if (i.userId == userid && i.role == "admin") {
                      currentUserIsAdmin = true;
                      break;
                    }
                  }
                });
                groupDetailModel =
                    await ChallengeApi().challengeGroupDetail(groupID: getxEnrollChallenge.groupId);
                Get.back();
                Get.to(CertificateDetail(
                  challengeDetail: _challengeDetail,
                  enrolledChallenge: getxEnrollChallenge,
                  groupDetail: groupDetailModel,
                  currentUserIsAdmin: currentUserIsAdmin,
                  firstCopmlete: false,
                ));
              } else {
                Get.back();
                Get.to(CertificateDetail(
                  challengeDetail: _challengeDetail,
                  enrolledChallenge: getxEnrollChallenge,
                  groupDetail: null,
                  currentUserIsAdmin: false,
                  firstCopmlete: false,
                ));
              }
            } else {
              null;
            }
          } else {
            if (getxEnrollChallenge.userProgress == null ||
                getxEnrollChallenge.userProgress == "requested" ||
                getxEnrollChallenge.userProgress == "") {
              Get.back();
              Get.to(PersistentOnGoingScreen(
                challengeStarted:
                    DateTime.now().isAfter(getxEnrollChallenge.challenge_start_time) ||
                        (DateFormat('MM-dd-yyyy')
                                .format(getxEnrollChallenge.challenge_start_time)
                                .toString() ==
                            "01-01-2000"),
                enrolledChallenge: getxEnrollChallenge,
                nrmlJoin: false,
                challengeDetail: _challengeDetail,
              ));
            } else if (getxEnrollChallenge.userProgress == "completed") {
              Get.back();
              Get.to(PersistentCertificateScreen(
                challengedetail: _challengeDetail,
                enrolledChallenge: getxEnrollChallenge,
                navNormal: false,
                firstComplete: false,
              ));
            } else {
              null;
            }
          }
        } else {
          Get.defaultDialog(
              barrierDismissible: true,
              backgroundColor: Colors.lightBlue.shade50,
              titlePadding: const EdgeInsets.only(top: 20, bottom: 10, right: 10, left: 10),
              titleStyle: TextStyle(letterSpacing: 1, color: Colors.blue.shade400, fontSize: 20),
              contentPadding: const EdgeInsets.only(top: 20, bottom: 10),
              content: const Text("Image not Uploaded"));
          update(['photoUpload']);
        }
      } else {
        null;
      }
    }
  }

  Future<File> waterMarkGene(ChallengeDetail challengeDetail) async {
    var rng = Random();
    try {
      if (getxEnrollChallenge.userAchieved > getxEnrollChallenge.target) {
        getxEnrollChallenge.userAchieved = getxEnrollChallenge.target.toDouble();
      }
    } catch (e) {
      debugPrint(e);
    }
    List<int> imageBytes = File(stepCroppedFile.path).readAsBytesSync();
    final ByteData bytes = await rootBundle.load('assets/images/overlapicons.png');
    final Uint8List list = bytes.buffer.asUint8List();
    var decodedImage = await decodeImageFromList(imageBytes);
    var h_p = (decodedImage.height / 100);
    var h_w = (decodedImage.width / 100);
    final wicn = await image_watermark.addTextWatermark(imageBytes, challengeDetail.challengeName,
        (h_w * 3).toInt(), (h_p * 5).toInt(), ui.arial_24,
        color: Colors.white);
    // Challenge Duration
    // final wid = await image_watermark.addTextWatermark(
    //     wicn, 'Duration :', (h_w * 40).toInt(), (h_p * 5).toInt(), ui.arial_14,
    //     color: Colors.white);
    final widu = await image_watermark.addTextWatermark(
        wicn,
        '${getxEnrollChallenge.userduration} mins       ${getxEnrollChallenge.userAchieved.toStringAsFixed(2)} ${challengeDetail.challengeUnit.replaceAll('kilometeres', 'kms').replaceAll('meters', 'm').replaceAll('kilometer', 'kms')}',
        (h_w * 5).toInt(),
        (h_p * 90).toInt(),
        ui.arial_24,
        color: Colors.white);
    // Challenge Duration
    // final widis = await image_watermark.addTextWatermark(
    //     widu, 'Distance :', (h_w * 60).toInt(), (h_p * 5).toInt(), ui.arial_14,
    //     color: Colors.white);
    // Unit
    // final wi = await image_watermark.addTextWatermark(
    //     widu,
    //     '${getxEnrollChallenge.userAchieved.toInt()} ${challengeDetail.challengeUnit}',
    //     (h_w * 30).toInt(),
    //     (h_p * 88).toInt(),
    //     ui.arial_14,
    //     color: Colors.white);
    print('Start Time ${DateTime.now()}');

    final tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    File file = await File('$tempPath' + (rng.nextInt(100)).toString() + '.png');
    file.writeAsBytesSync(widu);
    if (getxEnrollChallenge.selectedFitnessApp != 'other_apps') {
      return file;
    } else {
      return File(stepCroppedFile.path);
    }
  }

  RxList imageDatasObs = [].obs;
  Future<List<SelifeImageData>> getImageData({String enroll_id}) async {
    List<SelifeImageData> _temp;
    _temp = await ChallengeApi().getSelfieImageData(enroll_id: enroll_id);
    imageDatasObs.value = _temp;
    return _temp;
  }

  List<dynamic> imageDataLength = [];
  int len = 0;
}
