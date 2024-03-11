import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_exif_rotation/flutter_exif_rotation.dart';
import 'package:get/get.dart';
import 'package:ihl/constants/spKeys.dart';
import 'package:ihl/constants/vitalUI.dart';
import 'package:ihl/models/checkInternet.dart';
import 'package:ihl/new_design/app/utils/appColors.dart';
import 'package:ihl/new_design/app/utils/localStorageKeys.dart';
import 'package:ihl/new_design/presentation/pages/dashboard/common_screen_for_navigation.dart';
import 'package:ihl/new_design/presentation/pages/profile/profile_screen.dart';
import 'package:ihl/new_design/presentation/pages/profile/updatePhoto.dart';
import 'package:ihl/repositories/getuserData.dart';
import 'package:ihl/repositories/repositories.dart';
import 'package:ihl/utils/SpUtil.dart';
import 'package:ihl/utils/imageutils.dart';
import 'package:ihl/widgets/profileScreen/mobileService.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../constants/app_texts.dart';
import '../basicData/functionalities/draft_data.dart';

class MyProfile extends StatefulWidget {
  const MyProfile({Key key}) : super(key: key);

  @override
  State<MyProfile> createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  ValueNotifier<bool> isEditEnabled = ValueNotifier<bool>(false);
  final ValueNotifier<String> _selectedDate = ValueNotifier<String>('');
  TextEditingController name = TextEditingController();
  TextEditingController mobileNumber = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController ihlScore = TextEditingController();
  TextEditingController height = TextEditingController();
  TextEditingController weight = TextEditingController();
  TextEditingController gender = TextEditingController();
  TextEditingController dob = TextEditingController();
  TextEditingController address = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;
  ValueNotifier<TextEditingController> cityx =
      ValueNotifier<TextEditingController>(TextEditingController(text: ''));
  ValueNotifier<String> updatedCity = ValueNotifier<String>('');
  TextEditingController pincode = TextEditingController();
  TextEditingController country = TextEditingController();
  TextEditingController area = TextEditingController();
  TextEditingController state = TextEditingController();
  ValueNotifier<Image> photo = ValueNotifier<Image>(maleAvatar);
  ValueNotifier<bool> loading = ValueNotifier(true);
  final _formKey = GlobalKey<FormState>();
  String emailOld = '';
  String mobileNumberOld = '';
  final Apirepository _apirepository = Apirepository();
  final GetData _update = GetData();
  String userAffiliation = '';
  bool isTeleMedPolicyAgreed;
  bool isSelected = false;
  // Special Character check
  final _specialCharacterPattern = RegExp(r'^[a-zA-Z0-9 ]+$');
  ValueNotifier<bool> isMale = new ValueNotifier(true);
  // Image photo = maleAvatar;
  @override
  void initState() {
    loadData();
    super.initState();
  }

  loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var data = prefs.get(SPKeys.userData);
    data = data == null || data == '' ? '{"User":{}}' : data;

    Map res = jsonDecode(data);
    if (res['User']['hasPhoto'] == true && res['User']['photo'] != null) {
      photo.value = imageFromBase64String(res['User']['photo']);
      PhotoChangeNotifier.photo.value = res['User']['photo'];
      PhotoChangeNotifier.photo.notifyListeners();
    } else {
      if (res['User']['gender'] == 'm') {
        photo.value = maleAvatar;
      } else if (res['User']['gender'] == 'f') {
        photo.value = femaleAvatar;
      } else {
        photo.value = defAvatar;
      }
    }
    photo.notifyListeners();
    var firstName = res['User']['firstName'];
    firstName ??= '';
    var lastName = res['User']['lastName'];
    lastName ??= '';
    name.text = firstName + ' ' + lastName;
    email.text = res['User']['email'];
    email.text ??= '';
    emailOld = email.text;
    mobileNumber.text = res['User']['mobileNumber'];
    mobileNumber.text ??= '';
    mobileNumberOld = mobileNumber.text;
    var dobr = res['User']['dateOfBirth'].toString();
    dob.text = dobr ?? '';
    dob.text ??= '01/01/2000';

    _selectedDate.value = dob.text;
    print(_selectedDate.value);
    _selectedDate.notifyListeners();
    gender.text = res['User']['gender'];
    gender.text ??= 'o';
    gender.text = genderAlign(gender.text);
    if (gender.text == 'Male') {
      isMale.value = true;
      isMale.notifyListeners();
    } else if (gender.text == 'Female') {
      isMale.value = false;
      isMale.notifyListeners();
    } else {
      isMale.value = true;
      isMale.notifyListeners();
    }
    if (res['User']['heightMeters'] is num) {
      height.text = (res['User']['heightMeters'] * 100).toInt().toString();
    }

    height.text ??= '';
    var weightr = res['User']['userInputWeightInKG'].toString();
    weight.text = weightr ?? '';

    weight.text ??= '';
    var addressr = res['User']['address'].toString();
    address.text = addressr ?? 'NA';
    if (address.text == 'null') {
      address.text = 'NA';
    }
    var cityr = res['User']['city'].toString();
    cityx.value.text = cityr ?? 'NA';
    cityx.value.text ??= 'NA';
    if (cityx.value.text == 'null') {
      cityx.value.text = 'NA';
    }
    cityx.notifyListeners();
    var arear = res['User']['area'].toString();
    area.text = arear == 'null' ? 'NA' : arear;
    area.text ??= 'NA';
    var stater = res['User']['state'].toString();
    state.text = stater == 'null' ? 'NA' : stater;
    var pincoder = res['User']['pincode'].toString();

    var ihlScorer = SpUtil.getInt(LSKeys.ihlScore);
    ihlScore.text = ihlScorer.toString() ?? 'NA';
    ihlScore.text = ihlScore.text == '0' ? 'NA' : ihlScore.text;
    pincode.text = pincoder ?? '';
    pincode.text ??= 'NA';
    if (pincode.text == 'null') {
      pincode.text = 'NA';
    }
    userAffiliation = res['User']['affiliate'].toString();
    userAffiliation = AppTexts.affiliationOp.contains(userAffiliation) ? userAffiliation : 'none';
    isTeleMedPolicyAgreed = res['User']['isTeleMedPolicyAgreed'];
    isTeleMedPolicyAgreed = isTeleMedPolicyAgreed ?? false;
    print(userAffiliation);

    await getPostalApi(pincode.text);
  }

  static ValueNotifier<bool> isProgess = ValueNotifier(false);

  // bool isProgess = false;

  // Future<String> getCountryFromPincode(String pincode) async {
  //   String apiKey = 'AIzaSyDywpqHSTvZnQj6LoqLv_cKCR3-UAXQaUw';
  //   if (Platform.isAndroid) {
  //     apiKey = 'AIzaSyDywpqHSTvZnQj6LoqLv_cKCR3-UAXQaUw';
  //   }
  //   if (Platform.isIOS) {
  //     apiKey = 'AIzaSyA2xd6q_YXHnAG9nU5b5jrTbA8PsxrI5Dg';
  //   }
  //   final apiUrl =
  //       'https://maps.googleapis.com/maps/api/geocode/json?components=postal_code:$pincode&key=$apiKey';
  //   final Dio dio = Dio();
  //   final response = await dio.get(
  //     apiUrl,
  //   );
  //   //.get(Uri.parse(apiUrl));

  //   if (response.statusCode == 200) {
  //     final decodedResponse = response.data;
  //     final results = decodedResponse['results'] as List;

  //     if (results.isNotEmpty) {
  //       final addressComponents = results[0]['address_components'] as List;
  //       final countryComponent = addressComponents.firstWhere(
  //         (component) => component['types'].contains('country'),
  //         orElse: () => null,
  //       );

  //       if (countryComponent != null) {
  //         return countryComponent['long_name'] ?? '';
  //       }
  //     }
  //   }

  //   return 'NA'; // Country name not found or API request failed
  // }

  @override
  Widget build(BuildContext context) {
    DraftData saveData = DraftData();
    return CommonScreenForNavigation(
        appBar: AppBar(
          title: const Text('My Profile'),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(
              Icons.keyboard_arrow_left,
              size: 28.sp,
            ),
            onPressed: () {
              Get.off(const Profile());
            },
          ),
          elevation: 0,
          actions: [
            ValueListenableBuilder(
                valueListenable: isEditEnabled,
                builder: (_, check, __) {
                  return !check
                      ? Container(
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  print('tapped');
                                  isEditEnabled.value = true;
                                },
                                child: Icon(
                                  Icons.edit,
                                  size: 20.sp,
                                ),
                              ),
                              SizedBox(
                                width: 22.sp,
                              )
                            ],
                          ),
                        )
                      : Container(
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  if (!isProgess.value) {
                                    print('tapped');
                                    isProgess.value = true;
                                    // country.text = await getPostalApi(pincode.text);
                                    await getPostalApi(pincode.text);
                                    await _submit();
                                    isProgess.value = false;
                                  }
                                },
                                child: Icon(
                                  Icons.save,
                                  size: 20.sp,
                                ),
                              ),
                              SizedBox(
                                width: 22.sp,
                              ),
                            ],
                          ),
                        );
                }),
          ],
        ),
        content: SizedBox(
          height: 100.h,
          child: ValueListenableBuilder(
              valueListenable: isEditEnabled,
              builder: (_, check, __) {
                return SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    children: [
                      if (check == false)
                        Container(
                          padding: EdgeInsets.only(left: 15.sp, right: 15.sp, top: 20.sp),
                          width: 100.w,
                          height: 80.h,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 18.h,
                                  child: Center(
                                    child: Stack(
                                      children: [
                                        GestureDetector(
                                          onTap: () {},
                                          child: ValueListenableBuilder(
                                              valueListenable: photo,
                                              builder: (_, pic, __) {
                                                return Container(
                                                  height: 22.h,
                                                  width: 28.w,
                                                  decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      image: DecorationImage(
                                                          fit: BoxFit.cover,
                                                          image: photo.value.image.isBlank
                                                              ? const NetworkImage(
                                                                  'https://th.bing.com/th/id/R.b4540f74398560af0e659238046e33a1?rik=si%2btArRvvTcfVg&riu=http%3a%2f%2fwww.solidbackgrounds.com%2fimages%2f1280x1024%2f1280x1024-light-gray-solid-color-background.jpg&ehk=FUNd9SgkDZVH6OXUIvfUIWLwcBIvwcJjnYomAJc4VKo%3d&risl=&pid=ImgRaw&r=0')
                                                              : pic.image)),
                                                );
                                              }),
                                        ),
                                        // Positioned(
                                        //     bottom: 1.h,
                                        //     right: 0,
                                        //     child: GestureDetector(
                                        //       onTap: () {
                                        //         Get.to(const EditProfileScreen(
                                        //           kisokAccountWithoutWeight: false,
                                        //         ));
                                        //       },
                                        //       child: Container(
                                        //         height: 40,
                                        //         width: 40,
                                        //         decoration: const BoxDecoration(
                                        //             color: Color(0xffffffff), shape: BoxShape.circle),
                                        //         child: const Icon(Icons.camera_alt_sharp),
                                        //       ),
                                        //     ))
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10.sp),
                                nameColumn('NAME', name),
                                nameColumn('MOBILE NUMBER', mobileNumber),
                                nameColumn('EMAIL', email),
                                nameColumn('HEALTH SCORE', ihlScore),
                                nameColumn('HEIGHT', height),
                                nameColumn('WEIGHT', weight),
                                nameColumn('GENDER', gender),
                                nameColumn('DATE OF BIRTH', dob),
                                nameColumn('ADDRESS', address),
                                nameColumn('CITY', cityx.value),
                                nameColumn('PINCODE', pincode),
                                nameColumn('COUNTRY', country),
                                SizedBox(height: 30.sp),
                              ],
                            ),
                          ),
                        ),
                      if (check == true)
                        Container(
                          padding: EdgeInsets.only(left: 15.sp, right: 15.sp, top: 20.sp),
                          width: 100.w,
                          height: 80.h,
                          child: Form(
                            key: _formKey,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                            child: ValueListenableBuilder(
                                                valueListenable: photo,
                                                builder: (_, pic, __) {
                                                  return Container(
                                                    height: 22.h,
                                                    width: 28.w,
                                                    decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        image: DecorationImage(
                                                            fit: BoxFit.cover,
                                                            image: photo.value.image.isBlank
                                                                ? const NetworkImage(
                                                                    'https://th.bing.com/th/id/R.b4540f74398560af0e659238046e33a1?rik=si%2btArRvvTcfVg&riu=http%3a%2f%2fwww.solidbackgrounds.com%2fimages%2f1280x1024%2f1280x1024-light-gray-solid-color-background.jpg&ehk=FUNd9SgkDZVH6OXUIvfUIWLwcBIvwcJjnYomAJc4VKo%3d&risl=&pid=ImgRaw&r=0')
                                                                : pic.image)),
                                                  );
                                                }),
                                          ),
                                          Positioned(
                                              bottom: 1.h,
                                              right: 0,
                                              child: GestureDetector(
                                                onTap: () {
                                                  // Get.to(const EditProfileScreen(
                                                  //   kisokAccountWithoutWeight: false,
                                                  // ));
                                                  _cup(cont: context);
                                                },
                                                child: Container(
                                                  height: 40,
                                                  width: 40,
                                                  decoration: const BoxDecoration(
                                                      color: Color(0xffffffff),
                                                      shape: BoxShape.circle),
                                                  child: const Icon(Icons.camera_alt_sharp),
                                                ),
                                              ))
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 10.sp),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 15.sp),
                                      Text(
                                        'Name',
                                        style: TextStyle(
                                            fontSize: 16.sp,
                                            color: const Color(
                                              0xff19A9E5,
                                            ),
                                            fontWeight: FontWeight.w700),
                                      ),
                                      SizedBox(height: 3.sp),
                                      TextFormField(
                                        autovalidateMode: AutovalidateMode.always,
                                        decoration: const InputDecoration(
                                          enabledBorder: InputBorder.none,
                                        ),
                                        controller: name,
                                        validator: (value) {
                                          return nameValidator(value);
                                        },
                                        style: TextStyle(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w600,
                                            color: const Color.fromARGB(255, 128, 128, 128)),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 15.sp),
                                      Text(
                                        'MOBILE NUMBER',
                                        style: TextStyle(
                                            fontSize: 16.sp,
                                            color: const Color(
                                              0xff19A9E5,
                                            ),
                                            fontWeight: FontWeight.w700),
                                      ),
                                      SizedBox(height: 3.sp),
                                      TextFormField(
                                        autovalidateMode: AutovalidateMode.always,
                                        keyboardType: TextInputType.phone,
                                        focusNode: _focusNode,
                                        decoration: InputDecoration(
                                          enabledBorder: InputBorder.none,
                                          errorText: phoneValidator(mobileNumber.text),
                                          fillColor: Colors.red,
                                        ),
                                        controller: mobileNumber,
                                        validator: (value) {
                                          return phoneValidator(value);
                                        },
                                        style: TextStyle(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w600,
                                            color: const Color.fromARGB(255, 128, 128, 128)),
                                      ),
                                    ],
                                  ),

                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 15.sp),
                                      Text(
                                        'EMAIL',
                                        style: TextStyle(
                                            fontSize: 16.sp,
                                            color: const Color(
                                              0xff19A9E5,
                                            ),
                                            fontWeight: FontWeight.w700),
                                      ),
                                      SizedBox(height: 3.sp),
                                      TextFormField(
                                        autovalidateMode: AutovalidateMode.always,
                                        readOnly: true,
                                        decoration: const InputDecoration(
                                          enabledBorder: InputBorder.none,
                                        ),
                                        controller: email,
                                        validator: (value) {
                                          return emailValidator(value);
                                        },
                                        style: TextStyle(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w600,
                                            color: const Color.fromARGB(255, 128, 128, 128)),
                                      ),
                                    ],
                                  ),
                                  //  nameColumnTextField('IHLScore'.capitalize, ihlScore),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 15.sp),
                                      Text(
                                        'HEIGHT in cms',
                                        style: TextStyle(
                                            fontSize: 16.sp,
                                            color: const Color(
                                              0xff19A9E5,
                                            ),
                                            fontWeight: FontWeight.w700),
                                      ),
                                      SizedBox(height: 3.sp),
                                      TextFormField(
                                        autovalidateMode: AutovalidateMode.always,
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                          enabledBorder: InputBorder.none,
                                          errorText: heightValidator(height.text),
                                          fillColor: Colors.red,
                                        ),
                                        controller: height,
                                        validator: (value) {
                                          // double tryp = double.tryParse(value);
                                          // if (tryp == null || tryp < 0 || value.isEmpty) {
                                          //   return 'Enter Your Height';
                                          // }
                                          // if (tryp < 100) {
                                          //   return 'Min. Height Required 100 cm';
                                          // } else if (tryp > 250) {
                                          //   return 'Max. Height should be 250 cm';
                                          // }
                                          // return null;
                                          return heightValidator(value);
                                        },
                                        style: TextStyle(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w600,
                                            color: const Color.fromARGB(255, 128, 128, 128)),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 15.sp),
                                      Text(
                                        'WEIGHT in kgs',
                                        style: TextStyle(
                                            fontSize: 16.sp,
                                            color: const Color(
                                              0xff19A9E5,
                                            ),
                                            fontWeight: FontWeight.w700),
                                      ),
                                      SizedBox(height: 3.sp),
                                      TextFormField(
                                        autovalidateMode: AutovalidateMode.always,
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                          enabledBorder: InputBorder.none,
                                          errorText: weightValidator(weight.text),
                                          fillColor: Colors.red,
                                        ),
                                        controller: weight,
                                        validator: (value) {
                                          return weightValidator(value);
                                        },
                                        style: TextStyle(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w600,
                                            color: const Color.fromARGB(255, 128, 128, 128)),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 15.sp),
                                      Text(
                                        'GENDER',
                                        style: TextStyle(
                                            fontSize: 16.sp,
                                            color: const Color(
                                              0xff19A9E5,
                                            ),
                                            fontWeight: FontWeight.w700),
                                      ),
                                      SizedBox(height: 3.sp),
                                      ValueListenableBuilder(
                                          valueListenable: isMale,
                                          builder: (_, v, __) {
                                            return Wrap(
                                              spacing: 20.sp,
                                              children: [
                                                ChoiceChip(
                                                  avatar: Icon(Icons.male_rounded),
                                                  label: Text(
                                                    "Male",
                                                    style: TextStyle(color: Colors.black),
                                                  ),
                                                  selected: v,
                                                  backgroundColor: Colors.white,
                                                  disabledColor: Color.fromARGB(255, 178, 230, 253),
                                                  selectedColor: AppColors.ihlPrimaryColor,
                                                  onSelected: (value) {
                                                    isMale.value = true;
                                                    gender.text = 'Male';
                                                  },
                                                ),
                                                ChoiceChip(
                                                  onSelected: (value) {
                                                    gender.text = 'Female';
                                                    isMale.value = false;
                                                  },
                                                  avatar: Icon(Icons.female_rounded),
                                                  label: Text(
                                                    "Female",
                                                    style: TextStyle(color: Colors.black),
                                                  ),
                                                  selected: !v,
                                                  backgroundColor: Colors.white,
                                                  disabledColor: Color.fromARGB(255, 178, 230, 253),
                                                  selectedColor: AppColors.ihlPrimaryColor,
                                                ),
                                              ],
                                            );
                                          }),
                                      // TextFormField(
                                      //   autovalidateMode: AutovalidateMode.always,
                                      //   decoration: InputDecoration(
                                      //     enabledBorder: InputBorder.none,
                                      //     errorText: gendervalidator(gender.text),
                                      //     fillColor: Colors.red,
                                      //   ),
                                      //   controller: gender,
                                      //   // validator: (value) {
                                      //   //   return gendervalidator(value);
                                      //   // },
                                      //   style: TextStyle(
                                      //       fontSize: 16.sp,
                                      //       fontWeight: FontWeight.w600,
                                      //       color: const Color.fromARGB(255, 128, 128, 128)),
                                      // ),
                                    ],
                                  ),
                                  // nameColumnTextField('Name', dob),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(height: 15.sp),
                                          Text(
                                            'DATE OF BIRTH',
                                            style: TextStyle(
                                                fontSize: 16.sp,
                                                color: const Color(
                                                  0xff19A9E5,
                                                ),
                                                fontWeight: FontWeight.w700),
                                          ),
                                          SizedBox(height: 10.sp),
                                          ValueListenableBuilder(
                                              valueListenable: _selectedDate,
                                              builder: (_, selectedDate, __) {
                                                return Text(
                                                  selectedDate,
                                                  style: TextStyle(
                                                      fontSize: 16.sp,
                                                      fontWeight: FontWeight.w600,
                                                      color:
                                                          const Color.fromARGB(255, 128, 128, 128)),
                                                );
                                              }),
                                        ],
                                      ),
                                      GestureDetector(
                                          onTap: () {
                                            showDatePicker(
                                                    context: context,
                                                    initialDate: DateTime.now(),
                                                    firstDate: DateTime(1920),
                                                    lastDate: DateTime.now())
                                                .then((pickedDate) {
                                              DateFormat newFormat = DateFormat("MM/dd/yyyy");
                                              String updatedDt = newFormat.format(pickedDate);
                                              if (isAdult(updatedDt)) {
                                                _selectedDate.value = updatedDt;
                                              } else {
                                                Get.showSnackbar(
                                                  const GetSnackBar(
                                                    title: "Invalid Date",
                                                    message:
                                                        'Attention! You need to be 13 years or older to register with hCare.',
                                                    backgroundColor: AppColors.primaryAccentColor,
                                                    duration: Duration(seconds: 3),
                                                  ),
                                                );
                                              }

                                              //"${date.toLocal()}".split(' ')[0];
                                              // isDateSelected.value = true;
                                              // Check if no date is selected
                                              if (pickedDate == null) {
                                                return null;
                                              }

                                              // using state so that the UI will be rerendered when date is picked
                                              // _selectedDate.value = pickedDate;
                                              _selectedDate.notifyListeners();
                                            });
                                          },
                                          child: const Icon(Icons.calendar_month))
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 15.sp),
                                      Text(
                                        'ADDRESS',
                                        style: TextStyle(
                                            fontSize: 16.sp,
                                            color: const Color(
                                              0xff19A9E5,
                                            ),
                                            fontWeight: FontWeight.w700),
                                      ),
                                      SizedBox(height: 3.sp),
                                      TextFormField(
                                        autovalidateMode: AutovalidateMode.always,
                                        decoration: const InputDecoration(
                                          enabledBorder: InputBorder.none,
                                          fillColor: Colors.red,
                                        ),
                                        controller: address,
                                        validator: (String value) {
                                          return addressValidator(value);
                                        },
                                        style: TextStyle(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w600,
                                            color: const Color.fromARGB(255, 128, 128, 128)),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 15.sp),
                                      GestureDetector(
                                        onTap: () {
                                          FocusScope.of(context).unfocus();
                                        },
                                        child: Row(children: [
                                          Expanded(
                                            child: Text(
                                              'CITY',
                                              style: TextStyle(
                                                  fontSize: 16.sp,
                                                  color: const Color(
                                                    0xff19A9E5,
                                                  ),
                                                  fontWeight: FontWeight.w700),
                                            ),
                                          ),
                                        ]),
                                      ),
                                      SizedBox(height: 3.sp),
                                      TextFormField(
                                        autovalidateMode: AutovalidateMode.always,
                                        decoration: const InputDecoration(
                                          enabledBorder: InputBorder.none,
                                          fillColor: Colors.red,
                                        ),
                                        controller: cityx.value,
                                        validator: (String value) {
                                          return cityValidator(value);
                                        },
                                        style: TextStyle(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w600,
                                            color: const Color.fromARGB(255, 128, 128, 128)),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 15.sp),
                                      GestureDetector(
                                        onTap: () {
                                          FocusScope.of(context).unfocus();
                                        },
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                'PINCODE',
                                                style: TextStyle(
                                                    fontSize: 16.sp,
                                                    color: const Color(
                                                      0xff19A9E5,
                                                    ),
                                                    fontWeight: FontWeight.w700),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 3.sp),
                                      TextFormField(
                                        autovalidateMode: AutovalidateMode.always,
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                            enabledBorder: InputBorder.none,
                                            suffixIcon: Nprocessing
                                                ? Transform.scale(
                                                    scale: 0.5,
                                                    child: CircularProgressIndicator(
                                                      color: Colors.blue,
                                                    ),
                                                  )
                                                : null),
                                        initialValue: pincode.text,
                                        //controller: pincode,
                                        onChanged: (value) async {
                                          setState(() {
                                            Nprocessing = true;
                                          });
                                          await getPostalApi1(value);
                                          setState(() {
                                            Nprocessing = false;
                                          });
                                        },
                                        maxLength: 6,
                                        // onFieldSubmitted: (v) {
                                        //   if (v != null && v != '' && v.length == 6) {
                                        //     getPostalApi(v);
                                        //   }
                                        // },
                                        validator: (val) => valid ? null : "Invalid pincode",
                                        style: TextStyle(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w600,
                                            color: const Color.fromARGB(255, 128, 128, 128)),
                                      ),
                                    ],
                                  ),
                                  //   nameColumnTextField('COUNTRY'.capitalize, country),
                                  InkWell(
                                      onTap: () {
                                        FocusScope.of(context).unfocus();
                                      },
                                      child: SizedBox(height: 25.sp)),
                                  Center(
                                      child: SizedBox(
                                          height: 6.h,
                                          width: 27.w,
                                          child: ElevatedButton(
                                            onPressed: () async {
                                              if (_formKey.currentState?.validate() ?? false) {
                                                if (_selectedDate.value != null) {
                                                  if (isAdult(_selectedDate.value)) {
                                                    isProgess.value = true;
                                                    saveData.dob = _selectedDate.value;
                                                    try {
                                                      // country.text =
                                                      //     await getCountryFromPincode(pincode.text);
                                                      await getPostalApi(pincode.text);
                                                    } catch (e) {
                                                      print(e);
                                                    }

                                                    await _submit();
                                                  } else {
                                                    Get.showSnackbar(
                                                      const GetSnackBar(
                                                        title: "Invalid Date",
                                                        message:
                                                            'Attention! You need to be 13 years or older to register with hCare.',
                                                        backgroundColor:
                                                            AppColors.primaryAccentColor,
                                                        duration: Duration(seconds: 3),
                                                      ),
                                                    );
                                                  }
                                                } else {
                                                  Get.showSnackbar(
                                                    const GetSnackBar(
                                                      title: "Invalid Date",
                                                      message: 'Date Not Selected',
                                                      backgroundColor: AppColors.primaryAccentColor,
                                                      duration: Duration(seconds: 3),
                                                    ),
                                                  );
                                                }
                                              }
                                            },
                                            child: ValueListenableBuilder<bool>(
                                                valueListenable: isProgess,
                                                builder: (_, val, __) {
                                                  return Center(
                                                    child: val == true
                                                        ? Container(
                                                            padding: EdgeInsets.all(8.sp),
                                                            child: Transform.scale(
                                                              scale: 0.7,
                                                              child: CircularProgressIndicator(
                                                                color: Colors.white,
                                                              ),
                                                            ),
                                                          )
                                                        : Padding(
                                                            padding: EdgeInsets.all(8.sp),
                                                            child: Text('Save'),
                                                          ),
                                                  );
                                                }),
                                          ))),
                                  SizedBox(height: 20.h),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              }),
        ));
  }

  bool isAdult(String birthDateString) {
    String datePattern = "MM/dd/yyyy";

    // Current time - at this moment
    DateTime today = DateTime.now();

    // Parsed date to check
    DateTime birthDate = DateFormat(datePattern).parse(birthDateString);

    // Date to check but moved 13 years + 3 leap days ahead
    DateTime adultDate = DateTime(
      birthDate.year + 13,
      birthDate.month,
      birthDate.day + 3,
    );

    return adultDate.isBefore(today);
  }

  Column nameColumn(String title, TextEditingController controller) {
    if (title == 'HEIGHT') {
      title = '$title in cms';
    }
    if (title == 'WEIGHT') {
      title = '$title in kgs';
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 15.sp),
        Text(
          title,
          style: TextStyle(
              fontSize: 16.sp,
              color: const Color(
                0xff19A9E5,
              ),
              fontWeight: FontWeight.w700),
        ),
        SizedBox(height: 1.sp),
        TextFormField(
          decoration: const InputDecoration(
              enabledBorder: InputBorder.none, disabledBorder: InputBorder.none),
          readOnly: true,
          controller: controller,
          style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: const Color.fromARGB(255, 128, 128, 128)),
        ),
      ],
    );
  }

  Column nameColumnTextField(String title, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 15.sp),
        Text(
          title,
          style: TextStyle(
              fontSize: 16.sp,
              color: const Color(
                0xff19A9E5,
              ),
              fontWeight: FontWeight.w700),
        ),
        SizedBox(height: 3.sp),
        TextFormField(
          decoration: const InputDecoration(
            enabledBorder: InputBorder.none,
          ),
          controller: controller,
          validator: (value) {},
          style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: const Color.fromARGB(255, 128, 128, 128)),
        ),
      ],
    );
  }

  DateTime convertToDate(String input) {
    int day;
    int month;
    int year;
    if (input.contains('/')) {
      List<String> parts = input.split('/');
      day = int.parse(parts[1]);
      month = int.parse(parts[0]);
      year = int.parse(parts[2]);
    }
    if (input.contains('-')) {
      List<String> parts = input.split('-');
      day = int.parse(parts[1]);
      month = int.parse(parts[0]);
      year = int.parse(parts[2]);
    }
    print('${month}d$day $year');
    return DateTime(month, day, year);
  }

  String emailValidator(String mail) {
    bool isMail = mail.contains(
        RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+"), 0);
    if ((mail.isEmpty || !isMail)) {
      return 'Enter valid Email';
    }
  }

  // ignore: missing_return
  String nameValidator(String ip) {
    if (ip.length < 3) {
      return 'Min.3 characters required';
    }
    if (ip.toString().contains(RegExp(r'\d'))) {
      return 'Numbers are not allowed';
    }
    if (_specialCharacterPattern.hasMatch(ip)) {
      return null;
    } else {
      return 'Special characters are not allowed';
    }
  }

  String addressValidator(String ip) {
    if (ip.length < 10) {
      return 'Min. 10 characters required';
    }
    // if (_specialCharacterPattern.hasMatch(ip)) {
    //   return null;
    // } else {
    //   return 'Special characters are not allowed';
    // }
  }

  // ignore: missing_return
  zipValidator(String numb) {
    int tryp = int.tryParse(numb);
    if (tryp == null || numb.isEmpty) {
      return 'Please enter pincode.';
    }
    if (numb.length < 5) {
      return 'PIN code must be a minimum of 6 digits';
    }
  }

  Future getPostalApi(var numb) async {
    Map<String, String> countryCodes = {
      "IN": "India",
      "RO": "Romania",
      "RU": "Russia",
      "US": "United States", // America
      "GB": "United Kingdom", // England
      "ZA": "South Africa", // Africa
      "FR": "France",
      "AE": "United Arab Emirates",
      "BR": "Brazil",
      "CA": "Canada",
      "LK": "Sri Lanka",
      "SA": "Saudi Arabia",
      "DE": "Germany",
      "SG": "Singapore"
      // Add more country codes and names as needed
    };
    final Dio dio = Dio();
    try {
      final response = await dio.get("https://app.zipcodebase.com/api/v1/search?",
          options: Options(headers: {
            "apiKey": "ecc611f0-be79-11ee-b644-4b64e5d57326",
          }),
          queryParameters: {"codes": numb.toString()});
      if (response.statusCode == 200) {
        print(response.runtimeType);
        var output = response.data;

        // Extract results for the given postal code
        List<dynamic> results = output['results']['${numb}'];

        // Check if results contain at least one entry
        if (results != null && results.isNotEmpty) {
          // Postal code is valid, bind the city
          pincode.text = numb;
          String city = results[0]['city'];
          String countrry = countryCodes[results[0]['country_code']];
          if (numb.length >= 5 && countrry != null) {
            country.text = countrry.toString();
          } else {
            country.text = "India";
            // Postal code is not valid
            print('Postal code is not valid.');
          }
        }
      }
    } catch (e) {
      print(e);
    }
  }

  bool Nprocessing = false;
  bool valid = true;
  Future getPostalApi1(var numb) async {
    if (numb.length > 4) {
      final Dio dio = Dio();
      try {
        final response = await dio.get("https://app.zipcodebase.com/api/v1/search?",
            options: Options(headers: {
              "apiKey": "ecc611f0-be79-11ee-b644-4b64e5d57326",
            }),
            queryParameters: {"codes": numb.toString()});
        if (response.statusCode == 200) {
          print(response.runtimeType);
          var output = response.data;

          // Extract results for the given postal code
          List<dynamic> results = output['results']['${numb}'];

          // Check if results contain at least one entry
          if (results != null && results.isNotEmpty) {
            // Postal code is valid, bind the city
            pincode.text = numb;
            String city = results[0]['city'];
            String countrry = countryCodes[results[0]['country_code']];
            if (countrry != null) {
              valid = true;
              country.text = countrry.toString();
              setState(() {});
            } else {
              country.text = "India";
              valid = false;
              setState(() {});
            }
          }
        }
      } catch (e) {
        print(e);
      }
    } else {
      valid = false;
      setState(() {});
    }
  }

  Map<String, String> countryCodes = {
    "IN": "India",
    "RO": "Romania",
    "RU": "Russia",
    "US": "United States", // America
    "GB": "United Kingdom", // England
    "ZA": "South Africa", // Africa
    "FR": "France",
    "AE": "United Arab Emirates",
    "BR": "Brazil",
    "CA": "Canada",
    "LK": "Sri Lanka",
    "SA": "Saudi Arabia",
    "DE": "Germany",
    "SG": "Singapore",
    "OM": "Oman",
    "IE": "Ireland"
    // Add more country codes and names as needed
  };

  // ignore: missing_return
  String stateValidator(String ip) {
    if (ip.length < 3) {
      return 'The State name must contain at least 3 characters.';
    }
  }

  // ignore: missing_return
  String cityValidator(String ip) {
    if (ip.length < 3) {
      return 'The City name must have a minimum of 3 characters.';
    }
    if (ip.toString().contains(RegExp(r'\d'))) {
      return 'Numbers are not allowed';
    }
    if (_specialCharacterPattern.hasMatch(ip)) {
      return null;
    } else {
      return 'Special characters are not allowed';
    }
    return null;
  }

  // ignore: missing_return
  String areaValidator(String ip) {
    if (ip.length < 3) {
      return 'The City name must have a minimum of 3 characters.';
    }
  }

  // ignore: missing_return
  String phoneValidator(String numb) {
    int tryp = int.tryParse(numb);
    if (tryp == null || numb.isEmpty) {
      return 'Please enter a valid mobile number.';
    }
    if (numb.length != 10) {
      return 'The mobile number must be 10 digits.';
    }
    RegExp regex = RegExp(r'^[789]\d{9}$');
    if (!regex.hasMatch(numb)) {
      return 'Invalid number';
    }
    // return regex.hasMatch(numb).toString();
  }

  // ignore: missing_return
  String heightValidator(String numb) {
    // numb = numb.replaceAll('Cms', '');
    // numb = numb.replaceAll(' ', '');
    if (numb == "" || numb == null) {
      return "Can't be empty";
    }
    double tryp = double.parse(numb);
    if (tryp == null || tryp < 0 || numb.isEmpty) {
      return 'Invalid Height';
    }
    if (tryp < 100) {
      return 'Min. Height Required 100 cm';
    } else if (tryp > 250) {
      return 'Max. Height should be 250 cm';
    }
  }

  // ignore: missing_return
  String weightValidator(String numb) {
    // numb = numb.replaceAll('Kgs', '');
    // numb = numb.replaceAll(' ', '');
    if (numb == "" || numb == null) {
      return "Can't be empty";
    }
    double tryp = double.parse(numb);
    if (tryp == null || tryp < 0 || numb.isEmpty) {
      return 'Invalid Weight';
    }
    if (tryp < 25) {
      return 'Min. Weight Required : 25 Kg';
    } else if (tryp > 200) {
      return 'Max. Weight cannot surpass 200 Kg';
    }
    return null;
  }

  upload(File file, BuildContext context) {
    if (file == null) {
      return;
    }

    loading.value = true;
    loading.notifyListeners();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      backgroundColor: Colors.amber,
      content: Text('Uploading profile image'),
    ));
    String toUpload = base64String(file.readAsBytesSync());
    _apirepository.profileImageUpload(toUpload).then((value) {
      if (value.toString() == 'true') {
        _update.uptoUserInfoDate().then((val) {
          if (val == true) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              backgroundColor: Colors.green,
              content: Text('Successfully uploaded profile image'),
            ));

            loading.value = false;
            loading.notifyListeners();
            photo.value = imageFromBase64String(toUpload);
            PhotoChangeNotifier.photo.value = toUpload;
            PhotoChangeNotifier.photo.notifyListeners();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              backgroundColor: Colors.red,
              content: Text('Failed to upload image'),
            ));
            loading.value = false;
            loading.notifyListeners();
          }
        });
      } else {
        loading.value = false;
        loading.notifyListeners();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.red,
          content: Text('$value'),
        ));
      }
    }).catchError((error) {
      loading.value = false;
      loading.notifyListeners();
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
    print(permission);
    var isAllowed = await permission.request().isGranted;
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
      builder: (context) => CupertinoActionSheet(
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
    File fromPickImage;
    await _pickImage(context: context, source: source).then((value) async {
      if (value != null) {
        await crop(value);
      } else {
        loading.value = false;
        loading.notifyListeners();
      }
    });
  }

  Future crop(File selectedfile) async {
    try {
      await ImageCropper().cropImage(
        sourcePath: selectedfile.path,
        uiSettings: [
          AndroidUiSettings(
            lockAspectRatio: false,
            activeControlsWidgetColor: AppColors.primaryAccentColor,
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
          loading.value = false;
          loading.notifyListeners();
        }
      });
    } catch (e) {
      return selectedfile;
    }
  }

  Future _submit() async {
    Apirepository apiRepository = Apirepository();
    GetData updateData = GetData();
    if (_formKey.currentState.validate()) {
      FocusScope.of(context).unfocus();
      bool connection = await checkInternet();
      if (connection == false) {
        SnackBar snackBar = const SnackBar(
          content: Text('No internet connection. Please check and try again.'),
          backgroundColor: Colors.amber,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);

        return null;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.amber,
          content: Text('Checking Your Information...'),
        ),
      );
      String heightM = (double.tryParse(height.text.toString()) / 100).toString();
      try {
        bool mobilEMail = await validatePhoneEmail(context);
        String firstName;
        String secondName;
        print(name.text.toString().contains(' '));
        if (name.text.toString().contains(' ')) {
          List namex = name.text.toString().split(' ');
          firstName = namex[0];
          secondName = namex[1];
        } else {
          firstName = name.text;
          secondName = '';
        }
        String formattedDate = _selectedDate.value;

        if (mobilEMail == true) {
          await apiRepository
              .userProfileEditAPI(
                  firstName: firstName ?? name.text,
                  lastName: secondName ?? '',
                  email: email.text,
                  height: heightM,
                  userAffliation: userAffiliation ?? "none",
                  mobileNumber: mobileNumber.text,
                  weight: weight.text,
                  dob: formattedDate,
                  gender: isMale.value ? 'Male' : 'Female',
                  address: address.text,
                  area: area.text,
                  city: cityx.value.text,
                  state: state.text,
                  pincode: pincode.text,
                  isTeleMedPolicyAgreed: isTeleMedPolicyAgreed)
              .then((value) async {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                backgroundColor: Colors.amber,
                content: Text('Updating Your Profile...'),
              ),
            );

            bool resp = await updateData.uptoUserInfoDate();
            if (resp == true) {
              ModifiedData().cityName.value = updatedCity.value;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: AppColors.primaryAccentColor,
                  content: Text('Profile Successfully Updated'),
                ),
              );
              isEditEnabled.value = false;
            } else {
              print(resp);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: AppColors.primaryAccentColor,
                  content: Text('Unable to Update. Please Try Again. '),
                ),
              );
            }
          }).catchError((e) {
            print(e);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                backgroundColor: AppColors.primaryAccentColor,
                content: Text('Unable to Update. Please Try Again. '),
              ),
            );
          });
        }
      } catch (e) {
        print(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.primaryAccentColor,
            content: Text('Failed to update: $e'),
          ),
        );
      }
    } else {
      isProgess.value = false;
      isProgess.notifyListeners();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text('Fill correct information'),
        ),
      );

      return false;
    }
    isProgess.value = false;
    setState(() {});
  }

  bool mobileChanged() {
    return (mobileNumberOld != mobileNumber.text);
  }

  bool emailChanged() {
    return emailOld != email.text;
  }

  Future<bool> mobileEmailExist(moe) async {
    bool s = await MobileService.userExist(moe);
    return s;
  }

  Future<bool> validatePhoneEmail(BuildContext context) async {
    bool toSend = true;
    if (emailChanged()) {
      bool emailExist = await mobileEmailExist(email.text);
      if (emailExist == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text('Email ID already Registered'),
          ),
        );

        return false;
      } else {
        toSend = toSend && true;
      }
    }
    if (mobileChanged()) {
      bool mobileExists = await mobileEmailExist(mobileNumber.text);
      if (mobileExists == true) {
        _focusNode.addListener(() {
          setState(() {
            _isFocused = _focusNode.hasFocus;
          });
        });
        mobileNumber.text = mobileNumberOld;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text('Mobile No. already Registered'),
          ),
        );
        return false;
      }
      if (mobileExists == false) {
        bool otp = await MobileService.otpVerify(context: context, mobileNumber: mobileNumber.text);
        if (otp == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.green,
              content: Text('Mobile number successfully verified'),
            ),
          );
          isProgess.value = false;
          toSend = (toSend && true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.red,
              content: Text('Could not verify phone number'),
            ),
          );
          return false;
        }
      }
    }
    return toSend;
  }

  String genderAlign(String g) {
    if (g == 'm' || g == 'M' || g == 'male' || g == 'Male') {
      return 'Male';
    }
    if (g == 'f' || g == 'F' || g == 'female' || g == 'Female') {
      return 'Female';
    }
    if (g == 'o' || g == 'O' || g == 'others' || g == 'Others') {
      return 'Others';
    } else {
      return 'Male';
    }
  }

  String gendervalidator(String g) {
    if (g == 'm' || g == 'M' || g == 'male' || g == 'Male') {
      return null;
    }
    if (g == 'f' || g == 'F' || g == 'female' || g == 'Female') {
      return null;
    }
    if (g == 'o' || g == 'O' || g == 'others' || g == 'Others') {
      return null;
    } else {
      return 'Enter gender correctly!';
    }
  }
}

class ModifiedData {
  ValueNotifier<String> cityName = ValueNotifier('');
}
