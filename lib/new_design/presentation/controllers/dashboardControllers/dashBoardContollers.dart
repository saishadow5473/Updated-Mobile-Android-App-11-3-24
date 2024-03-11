import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Widgets/dashboardWidgets/affiliation_widgets.dart';
import '../../../app/utils/localStorageKeys.dart';
import '../../../data/model/affiliation_details_model.dart';
import '../../../data/providers/network/apis/dashboardApi/retriveUpcommingDetails.dart';
import '../../../data/providers/network/apis/get_affiliation_details.dart';
import '../../../../constants/api.dart';
import '../../../data/model/loginModel/userDataModel.dart';
import '../../../data/model/retriveUpcomingDetails/upcomingDetailsModel.dart';
import 'package:image/image.dart' as img;

class TabBarController extends GetxController {
  RxInt tabSelected = 0.obs;
  RxBool healthTipsFavorite = false.obs;
  RxInt programsTab = 0.obs;
  User userData;
  List<AffiliationDetailsModel> affiliationsAndDetails = [];

  String selectedBottomIcon = "Home";
  @override
  void onInit() async {
    if (affiliationsAndDetails != null) {
      affiliationsAndDetails.clear();
    }
    await afffliationDetailsGetter();
    super.onInit();
  }

  updateTab({@required int value}) {
    tabSelected.value = value;
  }

  afffliationDetailsGetter() async {
    List datas = await GetAffiliationDetails().affiliationDetailsGetter();
    try {
      for (var i in datas) {
        if (i["feature_settings"] != null) {
          String jsonString =
              i["feature_settings"].replaceAll('"', r'\"').replaceAll("&quot;", '"');
          jsonString = '"$jsonString"';
          i["feature_settings"] =
              jsonDecode(jsonString.substring(1, jsonString.length - 1))["feature_setting"];
        }
      }
    } catch (e) {
      print(e);
    }

    affiliationsAndDetails = datas.map((e) => AffiliationDetailsModel.fromJson(e)).toList();
    // var data = localSotrage.read(LSKeys.userDetail);
    var _prefs = await SharedPreferences.getInstance();
    var _userData = _prefs.getString(LSKeys.userDetail);
    dynamic data = jsonDecode(_userData);
    print(data);
    print(UpdatingColorsBasedOnAffiliations.ssoAffiliation);
    if (data != null) {
      userData = null;
      // try {
      //   userData = User.fromJson(data);
      // } catch (e) {
      //   print(e);
      // }
      try {
        print(data.containsKey('User'));
        if (data.containsKey('User')) {
          userData = User.fromJson(data['User']);
        } else {
          userData = User.fromJson(data);
        }
      } catch (e) {
        print(e);
      }
    }
    if (userData.userAffiliate.afNo1.affilateUniqueName != null) {
      affiliationsAndDetails.map((AffiliationDetailsModel e) async {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        if (e.affiliationUniqueName == userData.userAffiliate.afNo1.affilateUniqueName) {
          if (prefs.getString('SignInType') == 'okta') {
            String oktaUniqueName = prefs.getString('okta_unique_name');
            String oktaCompanyName = prefs.getString('okta_company_name');

            if (oktaUniqueName != userData.userAffiliate.afNo1.affilateUniqueName) {
              userData.userAffiliate.afNo1.affilateUniqueName = oktaUniqueName;
              userData.userAffiliate.afNo1.affilateName = oktaCompanyName;
              userData.userAffiliate.afNo1.imgUrl = e.brandImageUrl;
              userData.userAffiliate.afNo1.featureSettings = e.dashboardSettings;
            } else {
              userData.userAffiliate.afNo1.imgUrl = e.brandImageUrl;
              userData.userAffiliate.afNo1.featureSettings = e.dashboardSettings;
            }
          } else {
            userData.userAffiliate.afNo1.imgUrl = e.brandImageUrl;
            userData.userAffiliate.afNo1.featureSettings = e.dashboardSettings;
          }
        }
      }).toList();
    }
    if (userData.userAffiliate.afNo2.affilateUniqueName != null) {
      affiliationsAndDetails.map((AffiliationDetailsModel e) {
        if (e.affiliationUniqueName == userData.userAffiliate.afNo2.affilateUniqueName) {
          userData.userAffiliate.afNo2.imgUrl = e.brandImageUrl;
          userData.userAffiliate.afNo2.featureSettings = e.dashboardSettings;
        }
      }).toList();
    }
    if (userData.userAffiliate.afNo3.affilateUniqueName != null) {
      affiliationsAndDetails.map((AffiliationDetailsModel e) {
        if (e.affiliationUniqueName == userData.userAffiliate.afNo3.affilateUniqueName) {
          userData.userAffiliate.afNo3.imgUrl = e.brandImageUrl;
          userData.userAffiliate.afNo3.featureSettings = e.dashboardSettings;
        }
      }).toList();
    }
    if (userData.userAffiliate.afNo4.affilateUniqueName != null) {
      affiliationsAndDetails.map((AffiliationDetailsModel e) {
        if (e.affiliationUniqueName == userData.userAffiliate.afNo4.affilateUniqueName) {
          userData.userAffiliate.afNo4.imgUrl = e.brandImageUrl;
          userData.userAffiliate.afNo4.featureSettings = e.dashboardSettings;
        }
      }).toList();
    }
    if (userData.userAffiliate.afNo5.affilateUniqueName != null) {
      affiliationsAndDetails.map((AffiliationDetailsModel e) {
        if (e.affiliationUniqueName == userData.userAffiliate.afNo5.affilateUniqueName) {
          userData.userAffiliate.afNo5.imgUrl = e.brandImageUrl;
          userData.userAffiliate.afNo5.featureSettings = e.dashboardSettings;
        }
      }).toList();
    }
    if (userData.userAffiliate.afNo6.affilateUniqueName != null) {
      affiliationsAndDetails.map((AffiliationDetailsModel e) {
        if (e.affiliationUniqueName == userData.userAffiliate.afNo6.affilateUniqueName) {
          userData.userAffiliate.afNo6.imgUrl = e.brandImageUrl;
          userData.userAffiliate.afNo6.featureSettings = e.dashboardSettings;
        }
      }).toList();
    }
    if (userData.userAffiliate.afNo7.affilateUniqueName != null) {
      affiliationsAndDetails.map((AffiliationDetailsModel e) {
        if (e.affiliationUniqueName == userData.userAffiliate.afNo7.affilateUniqueName) {
          userData.userAffiliate.afNo7.imgUrl = e.brandImageUrl;
          userData.userAffiliate.afNo7.featureSettings = e.dashboardSettings;
        }
      }).toList();
    }
    if (userData.userAffiliate.afNo8.affilateUniqueName != null) {
      affiliationsAndDetails.map((AffiliationDetailsModel e) {
        if (e.affiliationUniqueName == userData.userAffiliate.afNo8.affilateUniqueName) {
          userData.userAffiliate.afNo8.imgUrl = e.brandImageUrl;
          userData.userAffiliate.afNo8.featureSettings = e.dashboardSettings;
        }
      }).toList();
    }
    if (userData.userAffiliate.afNo9.affilateUniqueName != null) {
      affiliationsAndDetails.map((AffiliationDetailsModel e) {
        if (e.affiliationUniqueName == userData.userAffiliate.afNo9.affilateUniqueName) {
          userData.userAffiliate.afNo9.imgUrl = e.brandImageUrl;
          userData.userAffiliate.afNo9.featureSettings = e.dashboardSettings;
        }
      }).toList();
    }
    userAffiliationsGetter();
    update(["User Affiliations"]);
  }

  List<AfNo> removeDuplicateAffis({List<AfNo> list}) {
    final List<AfNo> uniqueMaps = <AfNo>[];
    final dynamic seenKeys = <dynamic>{};

    for (final AfNo map in list) {
      final String keyValue = map.affilateUniqueName;

      if (!seenKeys.contains(keyValue)) {
        uniqueMaps.add(map);
        seenKeys.add(keyValue);
      }
    }

    return uniqueMaps;
  }

  updateFavorites({@required bool value}) {
    healthTipsFavorite.value = value;
  }

  updateProgramsTab({@required int val}) {
    programsTab.value = val;
  }

  updateSelectedIconValue({String value}) {
    selectedBottomIcon = value;
    update(["navigation_icons"]);
  }

  Future<String> getConsultantImageUrl({Map doctor}) async {
    try {
      String image = await RetriveDetials().getConsultantImageURL(doctor: doctor);
      // image = await compressBase64Image(image);
      return image;
    } catch (e) {
      print(e.toString());
      return AvatarImage.defaultUrl;
    }
  }

  getCourseImageURL({SubcriptionList subscriptionList}) {
    try {
      Future<String> image = RetriveDetials().getCourseImageURL(subcriptionList: subscriptionList);
      // image = compressBase64Image(image as String);
      return image;
    } catch (e) {
      print(e.toString());
      return AvatarImage.defaultUrl;
    }
  }

//Compressing the image based on the size of the image ⚪️
  Future<String> compressBase64Image(String base64String) async {
    try {
      Uint8List originalBytes = base64.decode(base64String);
      // Get the size of the image in kilobytes
      double imageSizeKB = originalBytes.length / 1024;
      if (imageSizeKB > 300) {
        // if (true) {
        ui.Image originalImage = await decodeImageFromList(originalBytes);
        int maxWidth = 100;
        int maxHeight = 100;
        int quality = 50;
        maxWidth = originalImage.width;
        maxHeight = originalImage.height;

        ui.Image resizedImage =
            await _resizeImage(ImageParameters(originalImage, maxWidth, maxHeight, quality));

        ByteData byteData = await resizedImage.toByteData(format: ui.ImageByteFormat.rawRgba);
        Uint8List rgbaBytes = byteData.buffer.asUint8List();

        img.Image image = img.Image.fromBytes(resizedImage.width, resizedImage.height, rgbaBytes);

        // Convert to JPEG with quality
        Uint8List compressedBytes = img.encodeJpg(image, quality: quality);
        double gettedImageSizeinKb = compressedBytes.length / 1024;
        if (gettedImageSizeinKb > 300) {
          return compressBase64Image(base64String);
        } else {
          String compressedBase64 = base64.encode(compressedBytes);
          return compressedBase64;
        }
      } else {
        return base64String;
      }
    } catch (e) {
      debugPrint('Error compressing image: $e');
      return null;
    }
  }

  Future<ui.Image> _resizeImage(ImageParameters params) async {
    ui.Image originalImage = params.originalImage;
    int maxWidth = params.maxWidth;
    int maxHeight = params.maxHeight;

    double aspectRatio = originalImage.width / originalImage.height;
    int newWidth, newHeight;

    if (originalImage.width > maxWidth || originalImage.height > maxHeight) {
      if (aspectRatio > 1.0) {
        newWidth = maxWidth;
        newHeight = (maxWidth / aspectRatio).round();
      } else {
        newHeight = maxHeight;
        newWidth = (maxHeight * aspectRatio).round();
      }
    } else {
      return originalImage;
    }

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    canvas.drawImageRect(
      originalImage,
      Rect.fromLTRB(0, 0, originalImage.width.toDouble(), originalImage.height.toDouble()),
      Rect.fromLTRB(0, 0, newWidth.toDouble(), newHeight.toDouble()),
      Paint(),
    );

    final picture = recorder.endRecording();
    return picture.toImage(newWidth, newHeight);
  }

  userAffiliationsGetter() {
    if (userData.userAffiliate.afNo1.affilateName == null ||
        userData.userAffiliate.afNo1.affilateName == "") {
      return [];
    } else {
      UserAffiliate userAffiliate = userData?.userAffiliate;
      List<AfNo> userAffiliateDatas = [];
      if (userAffiliate.afNo1.affilateUniqueName != null) {
        userAffiliateDatas.add(userAffiliate.afNo1);
      }
      if (userAffiliate.afNo2.affilateUniqueName != null) {
        userAffiliateDatas.add(userAffiliate.afNo2);
      }
      if (userAffiliate.afNo3.affilateUniqueName != null) {
        userAffiliateDatas.add(userAffiliate.afNo3);
      }
      if (userAffiliate.afNo4.affilateUniqueName != null) {
        userAffiliateDatas.add(userAffiliate.afNo4);
      }
      if (userAffiliate.afNo5.affilateUniqueName != null) {
        userAffiliateDatas.add(userAffiliate.afNo5);
      }
      if (userAffiliate.afNo6.affilateUniqueName != null) {
        userAffiliateDatas.add(userAffiliate.afNo6);
      }
      if (userAffiliate.afNo7.affilateUniqueName != null) {
        userAffiliateDatas.add(userAffiliate.afNo7);
      }
      if (userAffiliate.afNo8.affilateUniqueName != null) {
        userAffiliateDatas.add(userAffiliate.afNo8);
      }
      if (userAffiliate.afNo9.affilateUniqueName != null) {
        userAffiliateDatas.add(userAffiliate.afNo9);
      }

      String desiredValue = "ihl_care";

      userAffiliateDatas.sort((AfNo a, AfNo b) {
        if (a.affilateUniqueName == desiredValue) {
          return -1; // Move "ihl_care" to the front
        } else if (b.affilateUniqueName == desiredValue) {
          return 1; // Move "ihl_care" to the back
        } else {
          return a.affilateUniqueName
              .compareTo(b.affilateUniqueName); // Maintain the original order for other elements
        }
      });
      userAffiliateDatas.toSet().toList();
      return userAffiliateDatas;
    }
  }
}

class ImageParameters {
  final ui.Image originalImage;
  final int maxWidth;
  final int maxHeight;
  final int quality;

  ImageParameters(this.originalImage, this.maxWidth, this.maxHeight, this.quality);
}
