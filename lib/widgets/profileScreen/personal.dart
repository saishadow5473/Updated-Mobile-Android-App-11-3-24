import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../../abha/networks/network_calls_abha.dart';
import '../../abha/views/abha_account.dart';
import '../../abha/views/abha_id_download.dart';
import '../../constants/api.dart';
import '../../constants/app_texts.dart';
import '../../constants/routes.dart';
import '../../constants/spKeys.dart';
import '../../models/checkInternet.dart';
import '../../new_design/presentation/pages/basicData/functionalities/percentage_calculations.dart';
import '../../new_design/presentation/pages/basicData/models/basic_data.dart';
import '../../new_design/presentation/pages/basicData/screens/OtpVerificationScreen.dart';
import '../../new_design/presentation/pages/home/landingPage.dart';
import '../../new_design/presentation/pages/profile/profile_screen.dart';
import '../../repositories/api_repository.dart';
import '../../repositories/getuserData.dart';
import '../../utils/ScUtil.dart';
import '../../utils/app_colors.dart';
import '../height.dart';
import 'genderSelect.dart';
import 'mobileService.dart';
import 'photo.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:strings/strings.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../helper/checkForUpdate.dart';
import '../../new_design/presentation/pages/home/home_view.dart';
import '../../views/teleconsultation/new_speciality_type_screen.dart';

class PersonalDetails extends StatefulWidget {
  final bool fromTele;

  const PersonalDetails({Key key, this.fromTele}) : super(key: key);

  @override
  _PersonalDetailsState createState() => _PersonalDetailsState();
}

final String iHLUrl = API.iHLUrl;
final String ihlToken = API.ihlToken;

class _PersonalDetailsState extends State<PersonalDetails> {
  final http.Client _client = http.Client(); //3gb
  bool isloading = true;
  bool isChanging = false;
  bool isJoinAccount = true;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String firstName = '';
  String lastName = '';
  String email = '';
  String mobileNumber = '';
  String emailOld = '';
  String mobileNumberOld = '';
  String gender = '';
  String dob = '';
  String height = '';
  String weight = '';
  String address = '';
  String pincode = '';
  String area = '';
  String state = '';
  String city = '';
  String userAffiliation;
  bool isTeleMedPolicyAgreed;
  bool emailFixed = true;
  static final GetData _updateData = GetData();
  bool showWeight = true;
  static final Apirepository _apiRepository = Apirepository();
  List affiliations = [];
  List companies = [];
  String affiliationUniqueName;
  String afNo1, afNo2, afNo3, afNo4, afNo5, afNo6, afNo7, afNo8, afNo9;

  changeGender(String gen) {
    if (mounted) {
      setState(() {
        gender = gen;
      });
    }
  }

  bool mobileChanged() {
    return (mobileNumberOld != mobileNumber);
  }

  bool emailChanged() {
    return emailOld != email;
  }

  Future<bool> mobileEmailExist(moe) async {
    bool s = await MobileService.userExist(moe);
    return s;
  }

  Future<bool> otpVerification(BuildContext context) async {
    bool otpverify = await MobileService.otpVerify(context: context, mobileNumber: mobileNumber);
    return otpverify;
  }

  Future getAffiliateListAPI() async {
    final http.Response response = await _client.get(
      Uri.parse('${API.iHLUrl}/consult/get_list_of_affiliation'),
    );
    if (response.statusCode == 200) {
      companies = json.decode(response.body);
      for (int i = 0; i < companies.length; i++) {
        if (mounted) {
          setState(() {
            affiliations.add(companies[i]['company_name']);
          });
        }
      }
    } else {
      print(response.body);
    }
  }

  Future<void> getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Object data = prefs.get(SPKeys.userData);
    data = data == null || data == '' ? '{"User":{}}' : data;

    Map res = jsonDecode(data);
    firstName = res['User']['firstName'];
    firstName ??= '';
    lastName = res['User']['lastName'];
    lastName ??= '';
    email = res['User']['email'];
    email ??= '';
    emailOld = email;
    mobileNumber = res['User']['mobileNumber'];
    mobileNumber ??= '';
    mobileNumberOld = mobileNumber;
    dob = res['User']['dateOfBirth'].toString();
    dob = dob == 'null' ? '' : dob;
    dob ??= '01-01-2000';
    gender = res['User']['gender'];
    gender ??= 'o';
    if (res['User']['heightMeters'] is num) {
      height = (res['User']['heightMeters'] * 100).toInt().toString();
    }
    height ??= '';
    weight = res['User']['userInputWeightInKG'].toString();
    weight = weight == 'null' ? '' : weight;
    weight ??= '';
    address = res['User']['address'].toString();
    address = address == 'null' ? '' : address;
    area = res['User']['area'].toString();
    area = area == 'null' ? '' : area;
    city = res['User']['city'].toString();
    city = city == 'null' ? '' : city;
    state = res['User']['state'].toString();
    state = state == 'null' ? '' : state;
    pincode = res['User']['pincode'].toString();
    pincode = pincode == 'null' ? '' : pincode;
    isTeleMedPolicyAgreed = res['User']['isTeleMedPolicyAgreed'];
    isTeleMedPolicyAgreed = isTeleMedPolicyAgreed ?? false;

    afNo1 ??= "empty";
    afNo2 ??= "empty";
    afNo3 ??= "empty";
    afNo4 ??= "empty";
    afNo5 ??= "empty";
    afNo6 ??= "empty";
    afNo7 ??= "empty";
    afNo8 ??= "empty";
    afNo9 ??= "empty";

    var userAffiliate = res['User']['user_affiliate'];
    if (userAffiliate != null) {
      if (userAffiliate.containsKey("af_no1")) {
        afNo1 = userAffiliate['af_no1']['affilate_name'];
      }
      if (userAffiliate.containsKey("af_no2")) {
        afNo2 = userAffiliate['af_no2']['affilate_name'] ?? "empty";
      }
      if (userAffiliate.containsKey("af_no3")) {
        afNo3 = userAffiliate['af_no3']['affilate_name'] ?? "empty";
      }
      if (userAffiliate.containsKey("af_no4")) {
        afNo4 = userAffiliate['af_no4']['affilate_name'] ?? "empty";
      }
      if (userAffiliate.containsKey("af_no5")) {
        afNo5 = userAffiliate['af_no5']['affilate_name'] ?? "empty";
      }
      if (userAffiliate.containsKey("af_no6")) {
        afNo6 = userAffiliate['af_no6']['affilate_name'] ?? "empty";
      }
      if (userAffiliate.containsKey("af_no7")) {
        afNo7 = userAffiliate['af_no7']['affilate_name'] ?? "empty";
      }
      if (userAffiliate.containsKey("af_no8")) {
        afNo8 = userAffiliate['af_no8']['affilate_name'] ?? "empty";
      }
      if (userAffiliate.containsKey("af_no9")) {
        afNo9 = userAffiliate['af_no9']['affilate_name'] ?? "empty";
      }
    }

    if (res['LastCheckin'] != null &&
        (res['LastCheckin']['weightKG'] != null || res['LastCheckin']['weightKG'] != '')) {
      showWeight = false;
    }
    if (email == '' || email == null) {
      emailFixed = false;
    }
    firstNameController.text = firstName;
    lastNameController.text = lastName;
    emailController.text = email;
    mobileNumberController.text = mobileNumber;
    dobController.text = dob;
    heightController.text = height;
    weightController.text = weight;
    stateController.text = state;
    cityController.text = city;
    areaController.text = area;
    addressController.text = address;
    pincodeController.text = pincode;
    isloading = false;
    setState(() {});
  }

  String heightSuffix() {
    double h = double.tryParse(height);
    if (h == null) {
      return '';
    }
    return cmToFeetInch(h.toInt());
  }

  void formHandling() {
    if (mounted) {
      setState(() {
        isChanging = true;
      });
    }
    _submit();
  }

  Future _submit() async {
    if (_formKey.currentState.validate()) {
      FocusScope.of(context).unfocus();
      bool connection = await checkInternet();
      if (connection == false) {
        SnackBar snackBar = const SnackBar(
          content: Text('No internet connection. Please check and try again.'),
          backgroundColor: Colors.amber,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        if (mounted) {
          setState(() {
            isChanging = false;
          });
        }
        return null;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.amber,
          content: Text('Checking Your Information...'),
        ),
      );
      var checkAddress = false;
      String heightM = (double.tryParse(height) / 100).toString();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var data = prefs.get(SPKeys.userData);
      data = data == null || data == '' ? '{"User":{}}' : data;
      Map res = jsonDecode(data);
      print(res['User']['address'].toString().runtimeType);
      if (res['User']['address'] != null || res['User']['address'] != "null") {
        checkAddress = false;
        setState(() {});
      } else {
        checkAddress = true;
      }
      try {
        // bool mobilEMail = await validatePhoneEmail(context);
        // if (mobilEMail == true) {
        _apiRepository
            .userProfileEditAPI(
                firstName: firstName,
                lastName: lastName,
                email: email,
                height: heightM,
                userAffliation: userAffiliation ?? "none",
                mobileNumber: mobileNumber,
                weight: weight,
                dob: dob,
                gender: gender,
                address: address,
                area: area,
                city: city,
                state: state,
                pincode: pincode,
                isTeleMedPolicyAgreed: isTeleMedPolicyAgreed)
            .then((String value) async {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.amber,
              content: Text('Updating Your Profile...'),
            ),
          );
          //Uncomment the lines to add affiliation register
          //***these are important dont remove any commented line in this page
          /*String updatedAffiliation = await _updateData.updateAffiliation(
              affiliationUniqueName,
              userAffiliation,
              emailAffiliateController.text,
              mobileAffiliateController.text,
              "DE003");*/
          bool resp = await _updateData.uptoUserInfoDate();
          if (resp == true) {
            //&& updatedAffiliation == "AffiliationSuccessful") {
            // ScaffoldMessenger.of(context).showSnackBar(
            //   const SnackBar(
            //     backgroundColor: AppColors.primaryAccentColor,
            //     content: Text('Profile Successfully Updated'),
            //   ),
            // );
            // Get.to(ViewallTeleDashboard(
            //   backNav: false,
            // ));
            profileUpdated = true;
            checkAddress != true
                ? Get.to(OtpVerificationScreen(
                    mobileNumber: mobileNumber,
                    primaryEmail: true,
                    frompersonal: true,
                  ))
                : Get.to(NewSpecialtiyTypeScreen());
            if (mounted) {
              setState(() {
                isChanging = false;
                makeEmailMobileControllerVisible = false;
              });
            }
            getData();
          }
          /*else if(updatedAffiliation == "AffiliationFull") {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: AppColors.primaryAccentColor,
                content: Text('Affiliation is full; cannot add more than 9 affiliation per user'),
              ),
            );
            if(this.mounted) {
              setState(() {
                isChanging = false;
              });
            }
          }*/
          else {
            if (mounted) {
              setState(() {
                isChanging = false;
              });
            }
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                backgroundColor: AppColors.primaryAccentColor,
                content: Text('Unable to Update. Please Try Again. '),
              ),
            );
          }
        }).catchError((e) {
          if (mounted) {
            setState(() {
              isChanging = false;
            });
          }
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: AppColors.primaryAccentColor,
              content: Text('Unable to Update. Please Try Again. '),
            ),
          );
        });
      } catch (e) {
        if (mounted) {
          setState(() {
            isChanging = false;
          });
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.primaryAccentColor,
            content: Text('Unable to Update. Please Try Again.: $e'),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text('Fill correct information'),
        ),
      );
      if (mounted) {
        setState(() {
          isChanging = false;
        });
      }
      return false;
    }
  }

  String dateTimeToString(DateTime dateTime) {
    DateFormat ipF = DateFormat("MM/dd/yyyy");
    return ipF.format(dateTime);
  }

  DateTime stringToDateTime(String date) {
    if (date == '' || date == null) {
      return DateTime.now();
    } else {
      try {
        DateFormat ipF = DateFormat("MM/dd/yyyy");
        return ipF.parse(date);
      } catch (e) {
        try {
          DateFormat ipF = DateFormat("MM-dd-yyyy");
          return ipF.parse(date);
        } catch (e) {
          try {
            DateFormat ipF = DateFormat("dd/MM/yyyy");
            return ipF.parse(date);
          } catch (e) {
            try {
              DateFormat ipF = DateFormat("dd-MM-yyyy");
              return ipF.parse(date);
            } catch (e) {
              return DateTime.now();
            }
          }
        }
      }
    }
  }

  Future<bool> validatePhoneEmail(BuildContext context) async {
    bool toSend = true;
    if (emailChanged()) {
      bool emailExist = await mobileEmailExist(email);
      if (emailExist == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text('Email ID already Registered'),
          ),
        );
        if (mounted) {
          setState(() {
            isChanging = false;
          });
        }
        return false;
      } else {
        toSend = toSend && true;
      }
    }
    if (mobileChanged()) {
      bool mobileExists = await mobileEmailExist(mobileNumber);
      if (mobileExists == true) {
        if (mounted) {
          setState(() {
            isChanging = false;
          });
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text('Mobile No. already Registered'),
          ),
        );
        return false;
      }
      if (mobileExists == false) {
        bool otp = await MobileService.otpVerify(context: context, mobileNumber: mobileNumber);
        if (otp == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.green,
              content: Text('Mobile number successfully verified'),
            ),
          );
          toSend = (toSend && true);
        } else {
          setState(() {
            isChanging = false;
          });
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

  bool validate() {
    if (nameValidator(firstName) != null ||
        nameValidator(lastName) != null ||
        emailValidator(email) != null && emailValidator(email) == null ||
        phoneValidator(mobileNumber) != null && phoneValidator(mobileNumber) == null ||
        heightValidator(height) != null ||
        addressValidator(address) != null ||
        zipValidator(pincode) != null ||
        cityValidator(city) != null ||
        stateValidator(state) != null ||
        areaValidator(area) != null ||
        (weightValidator(weight) != null && showWeight)) {
      return false;
    }
    return true;
  }

//   Future accountDetails() async {
//   final prefs = await SharedPreferences.getInstance();

//   var userAccountDetails = prefs.getString('data');
//   var decodedResponse = jsonDecode(userAccountDetails);
//   print(decodedResponse);

//   bool isJointAccount = decodedResponse['User']['care_taker_details_list'];
// }

  // ignore: missing_return
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
  }

  // ignore: missing_return
  String addressValidator(String ip) {
    if (ip.length < 9) {
      return 'Min. 10 characters required';
    }
  }

  // ignore: missing_return
  zipValidator(String numb) {
    int tryp = int.tryParse(numb);
    if (tryp == null || numb.isEmpty) {
      return ' Incorrect PIN code.';
    }
    if (tryp < 99999) {
      return 'PIN code must be a minimum of 6 digits';
    } else {}
  }

  getPostalApi(var numb) async {
    final http.Response response = await _client.get(
      Uri.parse('https://api.postalpincode.in/pincode/' + numb),
    );
    if (response.statusCode == 200) {
      var output = json.decode(response.body);
      if (response.body != "" || response.body != null) {
        setState(() {
          String areaTemp = output[0]['PostOffice'][0]['Name'].toString();
          areaController.text = areaTemp == "" || areaTemp == null ? "" : areaTemp;
          area = areaController.text;
          String cityTemp =
              output[0]['PostOffice'][0]['Region'].toString().replaceAll("Region", "");
          cityController.text = cityTemp == "" || cityTemp == null ? "" : cityTemp;

          city = cityController.text;
          String stateTemp = output[0]['PostOffice'][0]['State'].toString();
          stateController.text = stateTemp == "" || stateTemp == null ? "" : stateTemp;

          state = stateController.text;
        });
      }
    }
  }

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
  }

  // ignore: missing_return
  String areaValidator(String ip) {
    if (ip.length < 3) {
      return 'The Area name must have a minimum of 3 characters.';
    }
  }

  // ignore: missing_return
  String phoneValidator(String numb) {
    int tryp = int.tryParse(numb);
    if (tryp == null || numb.isEmpty) {
      return 'Please enter a valid mobile number.';
    }
    if (tryp < 999999999) {
      return 'The mobile number must be 10 digits.';
    }
  }

  // ignore: missing_return
  String heightValidator(String numb) {
    double tryp = double.tryParse(numb);
    if (tryp == null || tryp < 0 || numb.isEmpty) {
      return 'Enter Your Height';
    }
    if (tryp < 100) {
      return 'Min. Height Required 100 cm ';
    } else if (tryp > 250) {
      return 'Max. Height should be 250 cm';
    }
  }

  // ignore: missing_return
  String weightValidator(String numb) {
    double tryp = double.tryParse(numb);
    if (tryp == null || tryp < 0 || numb.isEmpty) {
      return 'Enter Your Weight';
    }
    if (tryp < 25) {
      return 'Min. Weight Required : 25 Kg';
    } else if (tryp > 200) {
      return 'Max. Weight cannot surpass 200 Kg';
    }
  }

  @override
  void initState() {
    getAffiliateListAPI();
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    ScUtil.init(context, width: 360, height: 640, allowFontScaling: true);
    if (isloading) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 50),
        color: AppColors.bgColorTab,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Stack(
      alignment: Alignment.center,
      children: [
        Opacity(
          opacity: isChanging ? 0.5 : 1,
          child: AbsorbPointer(
            absorbing: isChanging,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                child: Form(
                  key: _formKey,
                  onWillPop: () async {
                    getData();
                    isloading = true;
                    return true;
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              flex: 2,
                              child: Text(
                                'Edit Your Details'.toUpperCase(),
                                style: TextStyle(
                                  fontSize: ScUtil().setSp(16),
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Align(alignment: Alignment.center, child: ProfilePhoto()),
                      const SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        autovalidateMode: AutovalidateMode.always,
                        controller: firstNameController,
                        keyboardType: TextInputType.visiblePassword,
                        maxLines: 1,
                        autocorrect: true,
                        onChanged: (String value) {
                          if (mounted) {
                            setState(() {
                              firstName = value;
                            });
                          }
                        },
                        style: TextStyle(
                          fontSize: ScUtil().setSp(16),
                        ),
                        decoration: InputDecoration(
                          disabledBorder: InputBorder.none,
                          border: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColors.primaryAccentColor,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(8),
                            ),
                          ),
                          labelStyle: TextStyle(
                              color: firstName == ''
                                  ? Colors.red
                                  : AppColors.appTextColor.withOpacity(0.6),
                              fontSize: ScUtil().setSp(20),
                              fontWeight: FontWeight.normal),
                          labelText: 'First Name',
                          errorText: nameValidator(firstName),
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      TextFormField(
                        autovalidateMode: AutovalidateMode.always,
                        keyboardType: TextInputType.visiblePassword,
                        controller: lastNameController,
                        onChanged: (String value) {
                          lastName = value;
                          if (mounted) {
                            setState(() => {});
                          }
                        },
                        style: TextStyle(
                          fontSize: ScUtil().setSp(16),
                        ),
                        decoration: InputDecoration(
                          disabledBorder: InputBorder.none,
                          border: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColors.primaryAccentColor,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(8),
                            ),
                          ),
                          errorText: nameValidator(lastName),
                          labelStyle: TextStyle(
                              color: lastName == ''
                                  ? Colors.red
                                  : AppColors.appTextColor.withOpacity(0.6),
                              fontSize: ScUtil().setSp(20),
                              fontWeight: FontWeight.normal),
                          labelText: 'Last Name',
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      TextFormField(
                        autovalidateMode: AutovalidateMode.always,
                        keyboardType: TextInputType.visiblePassword,
                        controller: emailController,
                        onChanged: (String value) {
                          if (mounted) {
                            setState(() {
                              email = value;
                            });
                          }
                        },
                        enabled: !emailFixed,
                        style: TextStyle(
                          fontSize: ScUtil().setSp(16),
                        ),
                        decoration: InputDecoration(
                          disabledBorder: InputBorder.none,
                          border: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColors.primaryAccentColor,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(8),
                            ),
                          ),
                          errorText: emailValidator(email),
                          labelStyle: TextStyle(
                              color: email == ''
                                  ? Colors.red
                                  : AppColors.appTextColor.withOpacity(0.6),
                              fontSize: ScUtil().setSp(20),
                              fontWeight: FontWeight.normal),
                          labelText: 'Email',
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      TextFormField(
                        autovalidateMode: AutovalidateMode.always,
                        keyboardType: TextInputType.phone,
                        validator: (String value) {
                          if (value.isNotEmpty) {
                            return null;
                          } else {
                            return zipValidator(pincode);
                          }
                        },
                        controller: pincodeController,
                        onChanged: (String value) {
                          pincode = value;
                          getPostalApi(value);
                          if (mounted) {
                            setState(() => {});
                          }
                        },
                        style: TextStyle(
                          fontSize: ScUtil().setSp(16),
                        ),
                        decoration: const InputDecoration(
                          disabledBorder: InputBorder.none,
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColors.primaryAccentColor,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(8),
                            ),
                          ),

                          // errorText: zipValidator(pincode),
                          // labelStyle: TextStyle(
                          //     color: pincode == ''
                          //         ? Colors.red
                          //         : AppColors.appTextColor.withOpacity(0.6),
                          //     fontSize: ScUtil().setSp(20),
                          //     fontWeight: FontWeight.normal),
                          labelText: 'Pin Code',
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      TextFormField(
                        autovalidateMode: AutovalidateMode.always,
                        keyboardType: TextInputType.visiblePassword,
                        controller: addressController,
                        validator: (String val) {
                          if (val.isEmpty || val.length < 10) {
                            return addressValidator(val);
                          } else {
                            return null;
                          }
                        },
                        onChanged: (String value) {
                          address = value;
                          if (mounted) {
                            setState(() => {});
                          }
                        },
                        style: TextStyle(
                          fontSize: ScUtil().setSp(16),
                        ),
                        decoration: const InputDecoration(
                          disabledBorder: InputBorder.none,
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColors.primaryAccentColor,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(8),
                            ),
                          ),
                          // labelStyle: TextStyle(
                          //     color: address == ''
                          //         ? Colors.red
                          //         : AppColors.appTextColor.withOpacity(0.6),
                          //     fontSize: ScUtil().setSp(20),
                          //     fontWeight: FontWeight.normal),
                          labelText: 'Address',
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      TextFormField(
                        autovalidateMode: AutovalidateMode.always,
                        keyboardType: TextInputType.visiblePassword,
                        controller: areaController,
                        validator: (String val) {
                          if (val.isEmpty || val.length < 3) {
                            return areaValidator(val);
                          } else {
                            return null;
                          }
                        },
                        onChanged: (String value) {
                          area = value;
                          if (mounted) {
                            setState(() => {});
                          }
                        },
                        style: TextStyle(
                          fontSize: ScUtil().setSp(16),
                        ),
                        decoration: const InputDecoration(
                          disabledBorder: InputBorder.none,
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColors.primaryAccentColor,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(8),
                            ),
                          ),
                          // errorText: areaValidator(area),
                          // labelStyle: TextStyle(
                          //     color: city == ''
                          //         ? Colors.red
                          //         : AppColors.appTextColor.withOpacity(0.6),
                          //     fontSize: ScUtil().setSp(20),
                          //     fontWeight: FontWeight.normal),
                          labelText: 'Area',
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      TextFormField(
                        autovalidateMode: AutovalidateMode.always,
                        keyboardType: TextInputType.visiblePassword,
                        controller: cityController,
                        validator: (String val) {
                          if (val.isEmpty || val.length < 3) {
                            return cityValidator(val);
                          } else {
                            return null;
                          }
                        },
                        onChanged: (String value) {
                          city = value;
                          if (mounted) {
                            setState(() => {});
                          }
                        },
                        style: TextStyle(
                          fontSize: ScUtil().setSp(16),
                        ),
                        decoration: const InputDecoration(
                          disabledBorder: InputBorder.none,
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColors.primaryAccentColor,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(8),
                            ),
                          ),
                          // errorText: cityValidator(city),
                          // labelStyle: TextStyle(
                          //     color: city == ''
                          //         ? Colors.red
                          //         : AppColors.appTextColor.withOpacity(0.6),
                          //     fontSize: ScUtil().setSp(20),
                          //     fontWeight: FontWeight.normal),
                          labelText: 'City',
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      TextFormField(
                        autovalidateMode: AutovalidateMode.always,
                        keyboardType: TextInputType.visiblePassword,
                        controller: stateController,
                        onChanged: (String value) {
                          state = value;
                          if (mounted) {
                            setState(() => {});
                          }
                        },
                        style: TextStyle(
                          fontSize: ScUtil().setSp(16),
                        ),
                        validator: (String val) {
                          if (val.isEmpty || val.length < 3) {
                            return stateValidator(val);
                          } else {
                            return null;
                          }
                        },
                        decoration: const InputDecoration(
                          disabledBorder: InputBorder.none,
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColors.primaryAccentColor,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(8),
                            ),
                          ),
                          // errorText: stateValidator(state),
                          // labelStyle: TextStyle(
                          //     color: state == ''
                          //         ? Colors.red
                          //         : AppColors.appTextColor.withOpacity(0.6),
                          //     fontSize: ScUtil().setSp(20),
                          //     fontWeight: FontWeight.normal),
                          labelText: 'State',
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      TextFormField(
                        autovalidateMode: AutovalidateMode.always,
                        controller: mobileNumberController,
                        keyboardType: TextInputType.phone,
                        onChanged: (String value) {
                          mobileNumber = value;
                          if (mounted) {
                            setState(() {});
                          }
                        },
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(10),
                        ],
                        style: TextStyle(
                          fontSize: ScUtil().setSp(16),
                        ),
                        decoration: InputDecoration(
                          errorText: phoneValidator(mobileNumber),
                          disabledBorder: InputBorder.none,
                          border: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColors.primaryAccentColor,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(8),
                            ),
                          ),
                          labelStyle: TextStyle(
                              color: mobileNumber == ''
                                  ? Colors.red
                                  : AppColors.appTextColor.withOpacity(0.6),
                              fontSize: ScUtil().setSp(20),
                              fontWeight: FontWeight.normal),
                          labelText: 'Mobile',
                        ),
                      ),
                      !emailFixed ? const Text('Mobile number cannot be changed') : Container(),
                      const SizedBox(
                        height: 15,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 1,
                            color: gender == '' || gender == null
                                ? Colors.red
                                : AppColors.appTextColor.withOpacity(0.6),
                          ),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(5.0),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Gender',
                                style: gender != null
                                    ? TextStyle(
                                        color: AppColors.appTextColor.withOpacity(0.6),
                                        fontSize: ScUtil().setSp(16),
                                        fontWeight: FontWeight.normal)
                                    : TextStyle(
                                        color: Colors.red,
                                        fontSize: ScUtil().setSp(20),
                                        fontWeight: FontWeight.normal),
                              ),
                            ),
                            GenderSelector(
                              change: changeGender,
                              current: gender,
                              isEditing: true,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      TextFormField(
                        autovalidateMode: AutovalidateMode.always,
                        controller: heightController,
                        keyboardType: TextInputType.number,
                        onChanged: (String value) {
                          height = value;
                          if (mounted) {
                            setState(() {});
                          }
                        },
                        style: TextStyle(
                          fontSize: ScUtil().setSp(16),
                        ),
                        decoration: InputDecoration(
                          errorText: heightValidator(height),
                          disabledBorder: InputBorder.none,
                          border: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColors.primaryAccentColor,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(8),
                            ),
                          ),
                          suffixText: heightSuffix(),
                          labelStyle: TextStyle(
                              color: height == ''
                                  ? Colors.red
                                  : AppColors.appTextColor.withOpacity(0.6),
                              fontSize: ScUtil().setSp(20),
                              fontWeight: FontWeight.normal),
                          labelText: 'Height(cm)',
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      showWeight
                          ? TextFormField(
                              autovalidateMode: AutovalidateMode.always,
                              controller: weightController,
                              keyboardType: TextInputType.number,
                              onChanged: (String value) {
                                weight = value;
                                if (mounted) {
                                  setState(() {});
                                }
                              },
                              style: TextStyle(
                                fontSize: ScUtil().setSp(16),
                              ),
                              decoration: InputDecoration(
                                errorText: weightValidator(weight),
                                disabledBorder: InputBorder.none,
                                border: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: AppColors.primaryAccentColor,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8),
                                  ),
                                ),
                                labelStyle: TextStyle(
                                    color: weight == ''
                                        ? Colors.red
                                        : AppColors.appTextColor.withOpacity(0.6),
                                    fontSize: ScUtil().setSp(20),
                                    fontWeight: FontWeight.normal),
                                labelText: 'Weight (kg)',
                              ),
                            )
                          : Container(),
                      const SizedBox(
                        height: 15,
                      ),
                      /*Padding(
                        // comment this padding widget to hide affiliation
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          padding: EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 1,
                              color: AppColors.appTextColor.withOpacity(0.6),
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(5.0),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Affiliation',
                                style: userAffiliation != ''
                                    ? TextStyle(
                                        color: AppColors.appTextColor
                                            .withOpacity(0.6),
                                        fontSize: ScUtil().setSp(15),
                                        fontWeight: FontWeight.normal)
                                    : TextStyle(
                                        color: Colors.red,
                                        fontSize: ScUtil().setSp(20),
                                        fontWeight: FontWeight.normal),
                              ),
                              DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                    hint: Text('Select'),
                                    value: userAffiliation,
                                    items: affiliations
                                        .map(
                                          (e) => DropdownMenuItem(
                                            child: Text(e.toString()),
                                            value: e.toString(),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (value) {
                                      if (this.mounted) {
                                        setState(() {
                                          userAffiliation = value;
                                        });
                                      }
                                      for (int i = 0;
                                          i < companies.length;
                                          i++) {
                                        if (companies[i]['company_name'] ==
                                            userAffiliation) {
                                          if (this.mounted) {
                                            setState(() {
                                              affiliationUniqueName = companies[
                                                  i]["affiliation_unique_name"];
                                            });
                                          }
                                        }
                                      }
                                      if (userAffiliation == afNo1 ||
                                          userAffiliation == afNo2 ||
                                          userAffiliation == afNo3 ||
                                          userAffiliation == afNo4 ||
                                          userAffiliation == afNo5 ||
                                          userAffiliation == afNo6 ||
                                          userAffiliation == afNo7 ||
                                          userAffiliation == afNo8 ||
                                          userAffiliation == afNo9) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            backgroundColor:
                                                AppColors.primaryAccentColor,
                                            content: Text(
                                                'You are already an affiliated user for this company!'),
                                          ),
                                        );
                                        if (this.mounted) {
                                          setState(() {
                                            makeEmailMobileControllerVisible =
                                                false;
                                          });
                                        }
                                      } else {
                                        if (this.mounted) {
                                          setState(() {
                                            makeEmailMobileControllerVisible =
                                                true;
                                          });
                                        }
                                      }
                                    }),
                              ),
                            ],
                          ),
                        ),
                      ),*/
                      const SizedBox(
                        height: 20,
                      ),
                      Visibility(
                        visible: makeEmailMobileControllerVisible ? true : false,
                        child: TextFormField(
                          autovalidateMode: AutovalidateMode.always,
                          controller: emailAffiliateController,
                          keyboardType: TextInputType.visiblePassword,
                          maxLines: 1,
                          autocorrect: true,
                          style: TextStyle(
                            fontSize: ScUtil().setSp(16),
                          ),
                          decoration: InputDecoration(
                            disabledBorder: InputBorder.none,
                            border: const OutlineInputBorder(
                              borderSide: BorderSide(
                                color: AppColors.primaryAccentColor,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.all(
                                Radius.circular(8),
                              ),
                            ),
                            labelStyle: TextStyle(
                                color: AppColors.appTextColor.withOpacity(0.6),
                                fontSize: ScUtil().setSp(20),
                                fontWeight: FontWeight.normal),
                            labelText: 'Affiliation Email',
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Visibility(
                        visible: makeEmailMobileControllerVisible ? true : false,
                        child: TextFormField(
                          autovalidateMode: AutovalidateMode.always,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(10),
                          ],
                          controller: mobileAffiliateController,
                          style: TextStyle(
                            fontSize: ScUtil().setSp(16),
                          ),
                          decoration: InputDecoration(
                            disabledBorder: InputBorder.none,
                            border: const OutlineInputBorder(
                              borderSide: BorderSide(
                                color: AppColors.primaryAccentColor,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.all(
                                Radius.circular(8),
                              ),
                            ),
                            labelStyle: TextStyle(
                                color: AppColors.appTextColor.withOpacity(0.6),
                                fontSize: ScUtil().setSp(20),
                                fontWeight: FontWeight.normal),
                            labelText: 'Affiliation Mobile',
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 1,
                            color: AppColors.appTextColor.withOpacity(0.6),
                          ),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(5.0),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Date of Birth',
                                  style: dob != ''
                                      ? TextStyle(
                                          color: AppColors.appTextColor.withOpacity(0.6),
                                          fontSize: ScUtil().setSp(15),
                                          fontWeight: FontWeight.normal)
                                      : TextStyle(
                                          color: Colors.red,
                                          fontSize: ScUtil().setSp(20),
                                          fontWeight: FontWeight.normal),
                                ),
                                Text(
                                  dob,
                                  style: TextStyle(
                                    color: AppColors.appTextColor.withOpacity(0.9),
                                    fontSize: ScUtil().setSp(16),
                                  ),
                                ),
                              ],
                            ),
                            TextButton(
                              style: TextButton.styleFrom(
                                backgroundColor: AppColors.primaryAccentColor,
                              ),
                              onPressed: () async {
                                DatePicker.showDatePicker(context,
                                    theme: const DatePickerTheme(
                                      itemStyle: TextStyle(
                                        color: Colors.black,
                                      ),
                                      containerHeight: 210.0,
                                    ),
                                    showTitleActions: true,
                                    minTime: DateTime(1900, 1, 1),
                                    maxTime: DateTime.now()
                                        .subtract(const Duration(days: (365 * 13) + 3)),
                                    onConfirm: (DateTime date) {
                                  dob = dateTimeToString(date);
                                  if (mounted) {
                                    setState(() {});
                                  }
                                }, currentTime: stringToDateTime(dob), locale: LocaleType.en);
                                return;
                              },
                              child: Text(
                                'Change',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          formHandling();
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: AppColors.primaryAccentColor,
                          padding: const EdgeInsets.all(0),
                        ),
                        child: Text(
                          'Save',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        isChanging
            ? const CircularProgressIndicator()
            : const SizedBox(
                height: 0,
                width: 0,
              )
      ],
    );
  }

  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController mobileNumberController = TextEditingController();
  TextEditingController genderController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  TextEditingController heightController = TextEditingController();
  TextEditingController weightController = TextEditingController();
  TextEditingController emailAffiliateController = TextEditingController();
  TextEditingController mobileAffiliateController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController pincodeController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController areaController = TextEditingController();
  bool makeEmailMobileControllerVisible = false;
}

class PersonalProfileDetails extends StatefulWidget {
  const PersonalProfileDetails({Key key, this.kisokAccountWithoutWeight}) : super(key: key);
  final bool kisokAccountWithoutWeight;

  @override
  _PersonalProfileDetailsState createState() => _PersonalProfileDetailsState();
}

class _PersonalProfileDetailsState extends State<PersonalProfileDetails> {
  bool isloading = true;
  bool isChanging = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String firstName = '';
  String lastName = '';
  String email = '';
  String mobileNumber = '';
  String emailOld = '';
  String mobileNumberOld = '';
  String gender = '';
  String dob = '';
  String height = '';
  String weight = '';
  String address = '';
  String pincode = '';
  String area = '';
  String state = '';
  String city = '';
  String userAffiliation;
  bool isTeleMedPolicyAgreed;
  bool emailFixed = true;
  static final GetData _updateData = GetData();
  bool showWeight = true;
  static final Apirepository _apiRepository = Apirepository();
  List affiliations = [];
  List companies = [];
  String affiliationUniqueName;
  String afNo1, afNo2, afNo3, afNo4, afNo5, afNo6, afNo7, afNo8, afNo9;

  changeGender(String gen) {
    if (mounted) {
      setState(() {
        gender = gen;
      });
    }
  }

  bool mobileChanged() {
    return (mobileNumberOld != mobileNumber);
  }

  bool emailChanged() {
    return emailOld != email;
  }

  Future<bool> mobileEmailExist(moe) async {
    bool s = await MobileService.userExist(moe);
    return s;
  }

  Future<bool> otpVerification(BuildContext context) async {
    bool otpverify = await MobileService.otpVerify(context: context, mobileNumber: mobileNumber);
    return otpverify;
  }

  Future getAffiliateListAPI() async {
    http.Client client = http.Client(); //3gb
    final http.Response response = await client.get(
      Uri.parse('${API.iHLUrl}/consult/get_list_of_affiliation'),
    );
    if (response.statusCode == 200) {
      companies = json.decode(response.body);
      for (int i = 0; i < companies.length; i++) {
        if (mounted) {
          setState(() {
            affiliations.add(companies[i]['company_name']);
          });
        }
      }
      print(affiliations);
    } else {
      print(response.body);
    }
  }

  Future<void> getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Object data = prefs.get(SPKeys.userData);
    data = data == null || data == '' ? '{"User":{}}' : data;

    Map res = jsonDecode(data);
    firstName = res['User']['firstName'];
    firstName ??= '';
    lastName = res['User']['lastName'];
    lastName ??= '';
    email = res['User']['email'];
    email ??= '';
    emailOld = email;
    mobileNumber = res['User']['mobileNumber'];
    mobileNumber ??= '';
    mobileNumberOld = mobileNumber;
    dob = res['User']['dateOfBirth'].toString();
    dob = dob == 'null' ? '' : dob;
    dob ??= '01-01-2000';
    gender = res['User']['gender'];
    gender ??= 'o';
    if (res['User']['heightMeters'] is num) {
      height = (res['User']['heightMeters'] * 100).toInt().toString();
    }
    height ??= '';
    weight = res['User']['userInputWeightInKG'].toString();
    weight = weight == 'null' ? '' : weight;
    weight ??= '';
    address = res['User']['address'].toString();
    address = address == 'null' ? '' : address;
    area = res['User']['area'].toString();
    area = area == 'null' ? '' : area;
    city = res['User']['city'].toString();
    city = city == 'null' ? '' : city;
    state = res['User']['state'].toString();
    state = state == 'null' ? '' : state;
    pincode = res['User']['pincode'].toString();
    pincode = pincode == 'null' ? '' : pincode;
    isTeleMedPolicyAgreed = res['User']['isTeleMedPolicyAgreed'];
    isTeleMedPolicyAgreed = isTeleMedPolicyAgreed ?? false;

    afNo1 ??= "empty";
    afNo2 ??= "empty";
    afNo3 ??= "empty";
    afNo4 ??= "empty";
    afNo5 ??= "empty";
    afNo6 ??= "empty";
    afNo7 ??= "empty";
    afNo8 ??= "empty";
    afNo9 ??= "empty";

    var userAffiliate = res['User']['user_affiliate'];
    if (userAffiliate != null) {
      if (userAffiliate.containsKey("af_no1")) {
        afNo1 = userAffiliate['af_no1']['affilate_name'];
      }
      if (userAffiliate.containsKey("af_no2")) {
        afNo2 = userAffiliate['af_no2']['affilate_name'] ?? "empty";
      }
      if (userAffiliate.containsKey("af_no3")) {
        afNo3 = userAffiliate['af_no3']['affilate_name'] ?? "empty";
      }
      if (userAffiliate.containsKey("af_no4")) {
        afNo4 = userAffiliate['af_no4']['affilate_name'] ?? "empty";
      }
      if (userAffiliate.containsKey("af_no5")) {
        afNo5 = userAffiliate['af_no5']['affilate_name'] ?? "empty";
      }
      if (userAffiliate.containsKey("af_no6")) {
        afNo6 = userAffiliate['af_no6']['affilate_name'] ?? "empty";
      }
      if (userAffiliate.containsKey("af_no7")) {
        afNo7 = userAffiliate['af_no7']['affilate_name'] ?? "empty";
      }
      if (userAffiliate.containsKey("af_no8")) {
        afNo8 = userAffiliate['af_no8']['affilate_name'] ?? "empty";
      }
      if (userAffiliate.containsKey("af_no9")) {
        afNo9 = userAffiliate['af_no9']['affilate_name'] ?? "empty";
      }
    }

    if (res['LastCheckin'] != null &&
        (res['LastCheckin']['weightKG'] != null || res['LastCheckin']['weightKG'] != '')) {
      showWeight = false;
    }
    if (email == '' || email == null) {
      emailFixed = false;
    }
    firstNameController.text = firstName;
    lastNameController.text = lastName;
    emailController.text = email;
    mobileNumberController.text = mobileNumber;
    dobController.text = dob;
    heightController.text = height;
    weightController.text = weight;
    stateController.text = state;
    cityController.text = city;
    areaController.text = area;
    addressController.text = address;
    pincodeController.text = pincode;
    isloading = false;
    setState(() {});
  }

  String heightSuffix() {
    double h = double.tryParse(height);
    if (h == null) {
      return '';
    }
    return cmToFeetInch(h.toInt());
  }

  void formHandling() {
    if (mounted) {
      setState(() {
        isChanging = true;
      });
    }
    _submit();
  }

  Future _submit() async {
    if (!validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text('Fill correct information'),
        ),
      );
      if (mounted) {
        setState(() {
          isChanging = false;
        });
      }
      return false;
    }
    FocusScope.of(context).unfocus();
    bool connection = await checkInternet();
    if (connection == false) {
      SnackBar snackBar = const SnackBar(
        content: Text('No internet connection. Please check and try again.'),
        backgroundColor: Colors.amber,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      if (mounted) {
        setState(() {
          isChanging = false;
        });
      }
      return null;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.amber,
        content: Text('Checking Your Information...'),
      ),
    );
    String heightM = (double.tryParse(height) / 100).toString();
    //Uncomment the lines to add affiliation register
    //***these are important dont remove any commented line in this page
    try {
      bool mobilEMail = await validatePhoneEmail(context);
      if (mobilEMail == true) {
        await _apiRepository
            .userProfileEditAPI(
                firstName: firstName,
                lastName: lastName,
                email: email,
                height: heightM,
                userAffliation: userAffiliation ?? "none",
                mobileNumber: mobileNumber,
                weight: weight,
                dob: dob,
                gender: gender,
                address: address,
                area: area,
                city: city,
                state: state,
                pincode: pincode,
                isTeleMedPolicyAgreed: isTeleMedPolicyAgreed)
            .then((String value) async {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.amber,
              content: Text('Updating Your Profile...'),
            ),
          );
          //Uncomment the lines to add affiliation register
          //***these are important dont remove any commented line in this page
          /*String updatedAffiliation = await _updateData.updateAffiliation(
              affiliationUniqueName,
              userAffiliation,
              emailAffiliateController.text,
              mobileAffiliateController.text,
              "DE003");*/
          bool resp = await _updateData.uptoUserInfoDate();
          if (resp == true) {
            //&& updatedAffiliation == "AffiliationSuccessful") {
            SharedPreferences pref1 = await SharedPreferences.getInstance();
            pref1.setInt('daily_target', 0);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                backgroundColor: AppColors.primaryAccentColor,
                content: Text('Profile Successfully Updated'),
              ),
            );
            if (mounted) {
              setState(() {
                isChanging = false;
                makeEmailMobileControllerVisible = false;
              });
            }
            getData();
            Navigator.pop(context);
            if (widget.kisokAccountWithoutWeight) {
              // Navigator.pushAndRemoveUntil(
              //     context,
              //     MaterialPageRoute(
              //         builder: (context) => HomeScreen(
              //               introDone: true,
              //             )),
              //     (Route<dynamic> route) => false);
              Get.off(LandingPage());
            } else {
              Get.off(const Profile());
            }
          }
          /*else if(updatedAffiliation == "AffiliationFull") {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: AppColors.primaryAccentColor,
                content: Text('Affiliation is full; cannot add more than 9 affiliation per user'),
              ),
            );
            if(this.mounted) {
              setState(() {
                isChanging = false;
              });
            }
          }*/
          else {
            if (mounted) {
              setState(() {
                isChanging = false;
              });
            }
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                backgroundColor: AppColors.primaryAccentColor,
                content: Text('Unable to Update. Please Try Again. '),
              ),
            );
          }
        }).catchError((e) {
          if (mounted) {
            setState(() {
              isChanging = false;
            });
          }
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: AppColors.primaryAccentColor,
              content: Text('Unable to Update. Please Try Again. '),
            ),
          );
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isChanging = false;
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.primaryAccentColor,
          content: Text('Unable to Update. Please Try Again. : $e'),
        ),
      );
    }
  }

  String dateTimeToString(DateTime dateTime) {
    DateFormat ipF = DateFormat("MM/dd/yyyy");
    return ipF.format(dateTime);
  }

  DateTime stringToDateTime(String date) {
    if (date == '' || date == null) {
      return DateTime.now();
    } else {
      try {
        DateFormat ipF = DateFormat("MM/dd/yyyy");
        return ipF.parse(date);
      } catch (e) {
        try {
          DateFormat ipF = DateFormat("MM-dd-yyyy");
          return ipF.parse(date);
        } catch (e) {
          try {
            DateFormat ipF = DateFormat("dd/MM/yyyy");
            return ipF.parse(date);
          } catch (e) {
            try {
              DateFormat ipF = DateFormat("dd-MM-yyyy");
              return ipF.parse(date);
            } catch (e) {
              return DateTime.now();
            }
          }
        }
      }
    }
  }

  Future<bool> validatePhoneEmail(BuildContext context) async {
    bool toSend = true;
    if (emailChanged()) {
      bool emailExist = await mobileEmailExist(email);
      if (emailExist == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text('Email ID already Registered'),
          ),
        );
        if (mounted) {
          setState(() {
            isChanging = false;
          });
        }
        return false;
      } else {
        toSend = toSend && true;
      }
    }
    if (mobileChanged()) {
      bool mobileExists = await mobileEmailExist(mobileNumber);
      if (mobileExists == true) {
        if (mounted) {
          setState(() {
            isChanging = false;
          });
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text('Mobile No. already Registered'),
          ),
        );
        return false;
      }
      if (mobileExists == false) {
        bool otp = await MobileService.otpVerify(context: context, mobileNumber: mobileNumber);
        if (otp == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.green,
              content: Text('Mobile number successfully verified'),
            ),
          );
          toSend = (toSend && true);
        } else {
          setState(() {
            isChanging = false;
          });
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

  bool validate() {
    if (nameValidator(firstName) != null ||
        nameValidator(lastName) != null ||
        emailValidator(email) != null && emailValidator(email) == null ||
        phoneValidator(mobileNumber) != null && phoneValidator(mobileNumber) == null ||
        heightValidator(height) != null ||
        addressValidator(address) != null ||
        zipValidator(pincode) != null ||
        cityValidator(city) != null ||
        stateValidator(state) != null ||
        areaValidator(area) != null ||
        (weightValidator(weight) != null && showWeight)) {
      return false;
    }
    return true;
  }

  // ignore: missing_return
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
  }

  // ignore: missing_return
  String addressValidator(String ip) {
    if (ip.length < 9) {
      return 'Min. 10 characters required';
    }
  }

  // ignore: missing_return
  zipValidator(String numb) {
    int tryp = int.tryParse(numb);
    if (tryp == null || numb.isEmpty) {
      return 'Incorrect PIN code.';
    }
    if (tryp < 99999) {
      return 'PIN code must be a minimum of 6 digits';
    } else {}
  }

  getPostalApi(var numb) async {
    http.Client client = http.Client(); //3gb
    final http.Response response = await client.get(
      Uri.parse('https://api.postalpincode.in/pincode/' + numb),
    );
    if (response.statusCode == 200) {
      var output = json.decode(response.body);
      if (response.body != "" || response.body != null) {
        setState(() {
          String areaTemp = output[0]['PostOffice'][0]['Name'].toString();
          areaController.text = areaTemp == "" || areaTemp == null ? "" : areaTemp;
          area = areaController.text;
          String cityTemp =
              output[0]['PostOffice'][0]['Region'].toString().replaceAll("Region", "");
          cityController.text = cityTemp == "" || cityTemp == null ? "" : cityTemp;

          city = cityController.text;
          String stateTemp = output[0]['PostOffice'][0]['State'].toString();
          stateController.text = stateTemp == "" || stateTemp == null ? "" : stateTemp;

          state = stateController.text;
        });
      }
    }
  }

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
    if (tryp < 999999999) {
      return 'The mobile number must be 10 digits.';
    }
  }

  // ignore: missing_return
  String heightValidator(String numb) {
    double tryp = double.tryParse(numb);
    if (tryp == null || tryp < 0 || numb.isEmpty) {
      return 'Enter Your Height';
    }
    if (tryp < 100) {
      return 'Min. Height Required 100 cm';
    } else if (tryp > 250) {
      return 'Max. Height should be 250 cm';
    }
  }

  // ignore: missing_return
  String weightValidator(String numb) {
    double tryp = double.tryParse(numb);
    if (tryp == null || tryp < 0 || numb.isEmpty) {
      return 'Enter Your Weight';
    }
    if (tryp < 25) {
      return 'Min. Weight Required : 25 Kg';
    } else if (tryp > 200) {
      return 'Max. Weight cannot surpass 200 Kg';
    }
  }

  @override
  void initState() {
    getAffiliateListAPI();
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    ScUtil.init(context, width: 360, height: 640, allowFontScaling: true);
    if (isloading) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 50),
        // color: AppColors.bgColorTab,
        color: FitnessAppTheme.white,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Stack(
      alignment: Alignment.center,
      children: [
        Opacity(
          opacity: isChanging ? 0.5 : 1,
          child: AbsorbPointer(
            absorbing: isChanging,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                child: Form(
                  key: _formKey,
                  onWillPop: () async {
                    getData();
                    isloading = true;
                    return true;
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              flex: 2,
                              child: Text(
                                'Edit Your Details'.toUpperCase(),
                                style: TextStyle(
                                  fontSize: ScUtil().setSp(17),
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Align(alignment: Alignment.center, child: ProfilePhoto()),
                      const SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        controller: firstNameController,
                        keyboardType: TextInputType.visiblePassword,
                        maxLines: 1,
                        autocorrect: true,
                        onChanged: (String value) {
                          if (mounted) {
                            setState(() {
                              firstName = value;
                            });
                          }
                        },
                        style: TextStyle(
                          fontSize: ScUtil().setSp(16),
                        ),
                        decoration: InputDecoration(
                          disabledBorder: InputBorder.none,
                          border: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColors.primaryAccentColor,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(8),
                            ),
                          ),
                          labelStyle: TextStyle(
                              color: firstName == ''
                                  ? Colors.red
                                  : AppColors.appTextColor.withOpacity(0.6),
                              fontSize: ScUtil().setSp(20),
                              fontWeight: FontWeight.normal),
                          labelText: 'First Name',
                          errorText: nameValidator(firstName),
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      TextFormField(
                        keyboardType: TextInputType.visiblePassword,
                        controller: lastNameController,
                        onChanged: (String value) {
                          lastName = value;
                          if (mounted) {
                            setState(() => {});
                          }
                        },
                        style: TextStyle(
                          fontSize: ScUtil().setSp(16),
                        ),
                        decoration: InputDecoration(
                          disabledBorder: InputBorder.none,
                          border: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColors.primaryAccentColor,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(8),
                            ),
                          ),
                          errorText: nameValidator(lastName),
                          labelStyle: TextStyle(
                              color: lastName == ''
                                  ? Colors.red
                                  : AppColors.appTextColor.withOpacity(0.6),
                              fontSize: ScUtil().setSp(20),
                              fontWeight: FontWeight.normal),
                          labelText: 'Last Name',
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      TextFormField(
                        keyboardType: TextInputType.visiblePassword,
                        controller: emailController,
                        onChanged: (String value) {
                          if (mounted) {
                            setState(() {
                              email = value;
                            });
                          }
                        },
                        enabled: !emailFixed,
                        style: TextStyle(
                          fontSize: ScUtil().setSp(16),
                        ),
                        decoration: InputDecoration(
                          disabledBorder: InputBorder.none,
                          border: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColors.primaryAccentColor,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(8),
                            ),
                          ),
                          errorText: emailValidator(email),
                          labelStyle: TextStyle(
                              color: email == ''
                                  ? Colors.red
                                  : AppColors.appTextColor.withOpacity(0.6),
                              fontSize: ScUtil().setSp(20),
                              fontWeight: FontWeight.normal),
                          labelText: 'Email',
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      TextFormField(
                        keyboardType: TextInputType.phone,
                        controller: pincodeController,
                        onChanged: (String value) {
                          pincode = value;
                          getPostalApi(value);
                          if (mounted) {
                            setState(() => {});
                          }
                        },
                        style: TextStyle(
                          fontSize: ScUtil().setSp(16),
                        ),
                        decoration: InputDecoration(
                          disabledBorder: InputBorder.none,
                          border: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColors.primaryAccentColor,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(8),
                            ),
                          ),
                          errorText: zipValidator(pincode),
                          labelStyle: TextStyle(
                              color: pincode == ''
                                  ? Colors.red
                                  : AppColors.appTextColor.withOpacity(0.6),
                              fontSize: ScUtil().setSp(20),
                              fontWeight: FontWeight.normal),
                          labelText: 'Pin Code',
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      TextFormField(
                        keyboardType: TextInputType.visiblePassword,
                        controller: addressController,
                        onChanged: (String value) {
                          address = value;
                          if (mounted) {
                            setState(() => {});
                          }
                        },
                        style: TextStyle(
                          fontSize: ScUtil().setSp(16),
                        ),
                        decoration: InputDecoration(
                          disabledBorder: InputBorder.none,
                          border: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColors.primaryAccentColor,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(8),
                            ),
                          ),
                          errorText: addressValidator(address),
                          labelStyle: TextStyle(
                              color: address == ''
                                  ? Colors.red
                                  : AppColors.appTextColor.withOpacity(0.6),
                              fontSize: ScUtil().setSp(20),
                              fontWeight: FontWeight.normal),
                          labelText: 'Address',
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      TextFormField(
                        keyboardType: TextInputType.visiblePassword,
                        controller: areaController,
                        onChanged: (String value) {
                          area = value;
                          if (mounted) {
                            setState(() => {});
                          }
                        },
                        style: TextStyle(
                          fontSize: ScUtil().setSp(16),
                        ),
                        decoration: InputDecoration(
                          disabledBorder: InputBorder.none,
                          border: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColors.primaryAccentColor,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(8),
                            ),
                          ),
                          errorText: areaValidator(area),
                          labelStyle: TextStyle(
                              color:
                                  city == '' ? Colors.red : AppColors.appTextColor.withOpacity(0.6),
                              fontSize: ScUtil().setSp(20),
                              fontWeight: FontWeight.normal),
                          labelText: 'Area',
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      TextFormField(
                        keyboardType: TextInputType.visiblePassword,
                        controller: cityController,
                        onChanged: (String value) {
                          city = value;
                          if (mounted) {
                            setState(() => {});
                          }
                        },
                        style: TextStyle(
                          fontSize: ScUtil().setSp(16),
                        ),
                        decoration: InputDecoration(
                          disabledBorder: InputBorder.none,
                          border: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColors.primaryAccentColor,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(8),
                            ),
                          ),
                          errorText: cityValidator(city),
                          labelStyle: TextStyle(
                              color:
                                  city == '' ? Colors.red : AppColors.appTextColor.withOpacity(0.6),
                              fontSize: ScUtil().setSp(20),
                              fontWeight: FontWeight.normal),
                          labelText: 'City',
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      TextFormField(
                        keyboardType: TextInputType.visiblePassword,
                        controller: stateController,
                        onChanged: (String value) {
                          state = value;
                          if (mounted) {
                            setState(() => {});
                          }
                        },
                        style: TextStyle(
                          fontSize: ScUtil().setSp(16),
                        ),
                        decoration: InputDecoration(
                          disabledBorder: InputBorder.none,
                          border: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColors.primaryAccentColor,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(8),
                            ),
                          ),
                          errorText: stateValidator(state),
                          labelStyle: TextStyle(
                              color: state == ''
                                  ? Colors.red
                                  : AppColors.appTextColor.withOpacity(0.6),
                              fontSize: ScUtil().setSp(20),
                              fontWeight: FontWeight.normal),
                          labelText: 'State',
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      TextFormField(
                        controller: mobileNumberController,
                        keyboardType: TextInputType.phone,
                        onChanged: (String value) {
                          mobileNumber = value;
                          if (mounted) {
                            setState(() {});
                          }
                        },
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(10),
                        ],
                        style: TextStyle(
                          fontSize: ScUtil().setSp(16),
                        ),
                        decoration: InputDecoration(
                          errorText: phoneValidator(mobileNumber),
                          disabledBorder: InputBorder.none,
                          border: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColors.primaryAccentColor,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(8),
                            ),
                          ),
                          labelStyle: TextStyle(
                              color: mobileNumber == ''
                                  ? Colors.red
                                  : AppColors.appTextColor.withOpacity(0.6),
                              fontSize: ScUtil().setSp(20),
                              fontWeight: FontWeight.normal),
                          labelText: 'Mobile',
                        ),
                      ),
                      !emailFixed ? const Text('Mobile number cannot be changed') : Container(),
                      const SizedBox(
                        height: 15,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 1,
                            color: AppColors.appTextColor.withOpacity(0.6),
                          ),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(5.0),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Gender',
                                style: gender != ''
                                    ? TextStyle(
                                        color: AppColors.appTextColor.withOpacity(0.6),
                                        fontSize: ScUtil().setSp(16),
                                        fontWeight: FontWeight.normal)
                                    : TextStyle(
                                        color: Colors.red,
                                        fontSize: ScUtil().setSp(20),
                                        fontWeight: FontWeight.normal),
                              ),
                            ),
                            GenderSelector(
                              change: changeGender,
                              current: gender,
                              isEditing: true,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      TextFormField(
                        controller: heightController,
                        keyboardType: TextInputType.number,
                        onChanged: (String value) {
                          height = value;
                          if (mounted) {
                            setState(() {});
                          }
                        },
                        style: TextStyle(
                          fontSize: ScUtil().setSp(16),
                        ),
                        decoration: InputDecoration(
                          errorText: heightValidator(height),
                          disabledBorder: InputBorder.none,
                          border: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColors.primaryAccentColor,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(8),
                            ),
                          ),
                          suffixText: heightSuffix(),
                          labelStyle: TextStyle(
                              color: height == ''
                                  ? Colors.red
                                  : AppColors.appTextColor.withOpacity(0.6),
                              fontSize: ScUtil().setSp(20),
                              fontWeight: FontWeight.normal),
                          labelText: 'Height(cm)',
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      showWeight
                          ? TextFormField(
                              controller: weightController,
                              keyboardType: TextInputType.number,
                              onChanged: (String value) {
                                weight = value;
                                if (mounted) {
                                  setState(() {});
                                }
                              },
                              style: TextStyle(
                                fontSize: ScUtil().setSp(16),
                              ),
                              decoration: InputDecoration(
                                errorText: weightValidator(weight),
                                disabledBorder: InputBorder.none,
                                border: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: AppColors.primaryAccentColor,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8),
                                  ),
                                ),
                                labelStyle: TextStyle(
                                    color: weight == ''
                                        ? Colors.red
                                        : AppColors.appTextColor.withOpacity(0.6),
                                    fontSize: ScUtil().setSp(20),
                                    fontWeight: FontWeight.normal),
                                labelText: 'Weight (kg)',
                              ),
                            )
                          : Container(),
                      const SizedBox(
                        height: 15,
                      ),
                      /*Padding(
                        // comment this padding widget to hide affiliation
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          padding: EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 1,
                              color: AppColors.appTextColor.withOpacity(0.6),
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(5.0),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Affiliation',
                                style: userAffiliation != ''
                                    ? TextStyle(
                                        color: AppColors.appTextColor
                                            .withOpacity(0.6),
                                        fontSize: ScUtil().setSp(15),
                                        fontWeight: FontWeight.normal)
                                    : TextStyle(
                                        color: Colors.red,
                                        fontSize: ScUtil().setSp(20),
                                        fontWeight: FontWeight.normal),
                              ),
                              DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                    hint: Text('Select'),
                                    value: userAffiliation,
                                    items: affiliations
                                        .map(
                                          (e) => DropdownMenuItem(
                                            child: Text(e.toString()),
                                            value: e.toString(),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (value) {
                                      if (this.mounted) {
                                        setState(() {
                                          userAffiliation = value;
                                        });
                                      }
                                      for (int i = 0;
                                          i < companies.length;
                                          i++) {
                                        if (companies[i]['company_name'] ==
                                            userAffiliation) {
                                          if (this.mounted) {
                                            setState(() {
                                              affiliationUniqueName = companies[
                                                  i]["affiliation_unique_name"];
                                            });
                                          }
                                        }
                                      }
                                      if (userAffiliation == afNo1 ||
                                          userAffiliation == afNo2 ||
                                          userAffiliation == afNo3 ||
                                          userAffiliation == afNo4 ||
                                          userAffiliation == afNo5 ||
                                          userAffiliation == afNo6 ||
                                          userAffiliation == afNo7 ||
                                          userAffiliation == afNo8 ||
                                          userAffiliation == afNo9) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            backgroundColor:
                                                AppColors.primaryAccentColor,
                                            content: Text(
                                                'You are already an affiliated user for this company!'),
                                          ),
                                        );
                                        if (this.mounted) {
                                          setState(() {
                                            makeEmailMobileControllerVisible =
                                                false;
                                          });
                                        }
                                      } else {
                                        if (this.mounted) {
                                          setState(() {
                                            makeEmailMobileControllerVisible =
                                                true;
                                          });
                                        }
                                      }
                                    }),
                              ),
                            ],
                          ),
                        ),
                      ),*/
                      const SizedBox(
                        height: 20,
                      ),
                      Visibility(
                        visible: makeEmailMobileControllerVisible ? true : false,
                        child: TextFormField(
                          controller: emailAffiliateController,
                          keyboardType: TextInputType.visiblePassword,
                          maxLines: 1,
                          autocorrect: true,
                          style: TextStyle(
                            fontSize: ScUtil().setSp(16),
                          ),
                          decoration: InputDecoration(
                            disabledBorder: InputBorder.none,
                            border: const OutlineInputBorder(
                              borderSide: BorderSide(
                                color: AppColors.primaryAccentColor,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.all(
                                Radius.circular(8),
                              ),
                            ),
                            labelStyle: TextStyle(
                                color: AppColors.appTextColor.withOpacity(0.6),
                                fontSize: ScUtil().setSp(20),
                                fontWeight: FontWeight.normal),
                            labelText: 'Affiliation Email',
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Visibility(
                        visible: makeEmailMobileControllerVisible ? true : false,
                        child: TextFormField(
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(10),
                          ],
                          controller: mobileAffiliateController,
                          style: TextStyle(
                            fontSize: ScUtil().setSp(16),
                          ),
                          decoration: InputDecoration(
                            disabledBorder: InputBorder.none,
                            border: const OutlineInputBorder(
                              borderSide: BorderSide(
                                color: AppColors.primaryAccentColor,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.all(
                                Radius.circular(8),
                              ),
                            ),
                            labelStyle: TextStyle(
                                color: AppColors.appTextColor.withOpacity(0.6),
                                fontSize: ScUtil().setSp(20),
                                fontWeight: FontWeight.normal),
                            labelText: 'Affiliation Mobile',
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 1,
                            color: AppColors.appTextColor.withOpacity(0.6),
                          ),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(5.0),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Date of Birth',
                                  style: dob != ''
                                      ? TextStyle(
                                          color: AppColors.appTextColor.withOpacity(0.6),
                                          fontSize: ScUtil().setSp(15),
                                          fontWeight: FontWeight.normal)
                                      : TextStyle(
                                          color: Colors.red,
                                          fontSize: ScUtil().setSp(20),
                                          fontWeight: FontWeight.normal),
                                ),
                                Text(
                                  dob,
                                  style: TextStyle(
                                    color: AppColors.appTextColor.withOpacity(0.9),
                                    fontSize: ScUtil().setSp(16),
                                  ),
                                ),
                              ],
                            ),
                            TextButton(
                              style: TextButton.styleFrom(
                                backgroundColor: AppColors.primaryAccentColor,
                              ),
                              onPressed: () async {
                                DatePicker.showDatePicker(context,
                                    theme: const DatePickerTheme(
                                      itemStyle: TextStyle(
                                        color: Colors.black,
                                      ),
                                      containerHeight: 210.0,
                                    ),
                                    showTitleActions: true,
                                    minTime: DateTime(1900, 1, 1),
                                    maxTime: DateTime.now()
                                        .subtract(const Duration(days: (365 * 13) + 3)),
                                    onConfirm: (DateTime date) {
                                  dob = dateTimeToString(date);
                                  if (mounted) {
                                    setState(() {});
                                  }
                                }, currentTime: stringToDateTime(dob), locale: LocaleType.en);
                                return;
                              },
                              child: Text(
                                'Change',
                                style: TextStyle(color: Colors.white),
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      TextButton(
                        onPressed: () {
                          formHandling();
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: AppColors.primaryAccentColor,
                          padding: const EdgeInsets.all(8),
                        ),
                        child: Text(
                          'Save',
                          style: TextStyle(color: Colors.white, fontSize: ScUtil().setSp(15)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        isChanging
            ? const CircularProgressIndicator()
            : const SizedBox(
                height: 0,
                width: 0,
              )
      ],
    );
  }

  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController mobileNumberController = TextEditingController();
  TextEditingController genderController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  TextEditingController heightController = TextEditingController();
  TextEditingController weightController = TextEditingController();
  TextEditingController emailAffiliateController = TextEditingController();
  TextEditingController mobileAffiliateController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController pincodeController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController areaController = TextEditingController();
  bool makeEmailMobileControllerVisible = false;
}

class PersonalDetailsCard extends StatefulWidget {
  const PersonalDetailsCard({Key key}) : super(key: key);

  @override
  _PersonalDetailsCardState createState() => _PersonalDetailsCardState();
}

class _PersonalDetailsCardState extends State<PersonalDetailsCard> {
  bool isloading = true;
  bool isChanging = false;
  bool s;
  String firstName = '';
  String lastName = '';
  String email = '';
  String mobileNumber = '';
  String emailOld = '';
  String mobileNumberOld = '';
  String gender = '';
  String address = '';
  String pincode = '';
  String area = '';
  String state = '';
  String city = '';
  String dob = '';
  String height = '';
  String weight = '';
  String weightfromvitalsData = '';
  String score = '';
  String userAffiliation = '';
  bool emailFixed = true;
  bool showWeight = true;
  bool feet = false;
  AppCheckerResult snapValue;

  Future<void> getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Object data = prefs.get(SPKeys.userData);
    double finalWeight = prefs.getDouble(SPKeys.weight);
    finalWeight = ((finalWeight ?? 0 * 100.0).toInt()) / 100;
    weightfromvitalsData = finalWeight.toString();
    data = data == null || data == '' ? '{"User":{}}' : data;
    Map res = jsonDecode(data);
    List notAns = [];

    res['User']['user_score'] ??= {};
    res['User']['user_score']['T'] ??= 'N/A';
    score = res['User']['user_score']['T'].toString();
    Map sscore = res['User']['user_score'];
    sscore.forEach((k, v) {
      if (v == 0) {
        notAns.add(k);
      }
    });
    notAns.remove('E1');
    notAns.remove('E2');
    notAns.remove('E3');
    notAns.remove('E4');
    if (notAns.isEmpty) {
      prefs.setBool('allAns', true);
    } else {
      prefs.setBool('allAns', false);
    }
    s = prefs.getBool('allAns');
    firstName = res['User']['firstName'];
    firstName ??= '';
    lastName = res['User']['lastName'];
    lastName ??= '';
    prefs.setString('name', '$firstName $lastName');
    email = res['User']['email'];
    email ??= '';
    emailOld = email;
    mobileNumber = res['User']['mobileNumber'];
    mobileNumber ??= '';
    prefs.setString('mobile', mobileNumber);
    mobileNumberOld = mobileNumber;
    dob = res['User']['dateOfBirth'].toString();
    dob = dob == 'null' ? '' : dob;
    dob ??= '01-01-2000';
    address = res['User']['address'].toString();
    address = address == 'null' ? 'Please Add Address to Book an Appointment' : address;
    area = res['User']['area'].toString();
    area = area == 'null' ? '' : area;
    city = res['User']['city'].toString();
    city = city == 'null' ? '' : city;
    state = res['User']['state'].toString();
    state = state == 'null' ? '' : state;
    pincode = res['User']['pincode'].toString();
    pincode = pincode == 'null' ? '' : pincode;
    gender = res['User']['gender'];
    gender ??= 'o';
    if (res['User']['heightMeters'] is num) {
      height = (res['User']['heightMeters'] * 100).toInt().toString();
    }
    height ??= '';
    if (weightfromvitalsData == null || weightfromvitalsData == 'null') {
      weightfromvitalsData = '';
    }
    if (res.length == 3) {
      if (res['LastCheckin']['weightKG'] != null) {
        weight = ((((res['LastCheckin']['weightKG']) * 100.0).toInt()) / 100).toString() ?? "";
      }
    }
    if (weight == null || weight == '') {
      weight = res['User']['userInputWeightInKG'];
    }

    weight = weight == 'null' ? '' : weight;
    weight ??= '';
    userAffiliation = res['User']['affiliate'].toString();
    userAffiliation = AppTexts.affiliationOp.contains(userAffiliation) ? userAffiliation : 'none';
    if (res['LastCheckin'] != null &&
        (res['LastCheckin']['weightKG'] != null || res['LastCheckin']['weightKG'] != '') &&
        res.length == 3) {
      showWeight = false;
    }
    if (email == '' || email == null) {
      emailFixed = false;
    }
    isloading = false;
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> chechAppVersion() async {
    final AppVersionChecker snapChatChecker =
        AppVersionChecker(appId: "com.indiahealthlink.ihlhealth");

    await Future.wait([
      snapChatChecker.checkUpdate().then((AppCheckerResult value) => snapValue = value),
    ]);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    getData();
    NetworkCallsAbha().getAccessToken();
    chechAppVersion();
  }

  void getAbhadata() async {
    dynamic response = await NetworkCallsAbha().viewAbhadetails();
    print(response.isEmpty);
    if (response.isEmpty) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => AbhaAccountLogin(abhaTextField: "phonenumber")));
    } else {
      print(response);
      var healthid = response[0]['abha_address'];
      var abhaNumber = response[0]['abha_number'];
      String abhaCard = await NetworkCallsAbha().viewAbhaCard(healthid);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => AbhaIdDownloadScreen(
                    abhaAddress: healthid,
                    abhaCard: abhaCard,
                    abhaNumber: abhaNumber,
                  )));
    }
  }

  @override
  Widget build(BuildContext context) {
    ScUtil.init(context, width: 360, height: 640, allowFontScaling: true);
    if (isloading) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 50),
        color: AppColors.bgColorTab,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Container(
        padding: const EdgeInsets.all(10),
        child: Card(
          child: Container(
            alignment: Alignment.topLeft,
            padding: const EdgeInsets.all(15),
            child: Column(
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Align(alignment: Alignment.center, child: ProfilePhoto()),
                    SizedBox(height: ScUtil().setHeight(10)),
                    Center(
                      child: RichText(
                        text: TextSpan(
                          text: '$firstName $lastName',
                          style: TextStyle(
                            color: AppColors.primaryColor,
                            fontSize: ScUtil().setSp(22),
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                    _buildInfoCard(context),
                    SizedBox(height: ScUtil().setHeight(15)),
                    ListTile(
                      leading: const Icon(
                        Icons.email,
                        color: AppColors.primaryColor,
                      ),
                      title: Text(
                        "E-Mail",
                        style: TextStyle(
                          fontSize: ScUtil().setSp(16),
                        ),
                      ),
                      subtitle: FittedBox(
                        child: Text(
                          email,
                          style: TextStyle(
                            fontSize: ScUtil().setSp(12),
                          ),
                        ),
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(
                        Icons.phone,
                        color: AppColors.primaryColor,
                      ),
                      title: Text(
                        "Phone Number",
                        style: TextStyle(
                          fontSize: ScUtil().setSp(16),
                        ),
                      ),
                      subtitle: Text(
                        mobileNumber,
                        style: TextStyle(
                          fontSize: ScUtil().setSp(14),
                        ),
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      leading: const Icon(
                        Icons.calendar_today,
                        color: AppColors.primaryColor,
                      ),
                      title: Text(
                        "Date of Birth",
                        style: TextStyle(
                          fontSize: ScUtil().setSp(16),
                        ),
                      ),
                      subtitle: Text(
                        dob,
                        style: TextStyle(
                          fontSize: ScUtil().setSp(14),
                        ),
                      ),
                    ),
                    // Divider(),
                    // GestureDetector(
                    //   onTap: () {
                    //     getAbhadata();
                    //   },
                    //   child: ListTile(
                    //     contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    //     leading: Icon(
                    //       Icons.link,
                    //       color: AppColors.primaryColor,
                    //     ),
                    //     title: Text(
                    //       "Abha health ID",
                    //       style: TextStyle(
                    //         fontSize: ScUtil().setSp(16),
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(
                        Icons.person,
                        color: AppColors.primaryColor,
                      ),
                      title: Text(
                        "Gender",
                        style: TextStyle(
                          fontSize: ScUtil().setSp(16),
                        ),
                      ),
                      subtitle: Text(
                        (gender == 'm' || gender == 'M' || gender == 'male' || gender == 'Male')
                            ? 'Male'
                            : (gender == 'f' ||
                                    gender == 'F' ||
                                    gender == 'female' ||
                                    gender == 'Female')
                                ? 'Female'
                                : 'Others',
                        style: TextStyle(
                          fontSize: ScUtil().setSp(14),
                        ),
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(
                        Icons.home,
                        color: AppColors.primaryColor,
                      ),
                      title: Text(
                        "Address",
                        style: TextStyle(
                          fontSize: ScUtil().setSp(16),
                        ),
                      ),
                      subtitle: Text(
                        "$address\n$area\n$city\n$state\n$pincode",
                        style: TextStyle(
                          fontSize: ScUtil().setSp(14),
                        ),
                      ),
                    ),
                    const Divider(),
                    _buildAppversionCard(context)
                  ],
                )
              ],
            ),
          ),
        ));
  }

  String heightft() {
    double h = double.tryParse(height);
    if (h == null) {
      return '';
    }
    return cmToFeetInch(h.toInt());
  }

  Future<bool> _survey(BuildContext context) {
    return showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Column(
                  children: [
                    const Text(
                      'Finish Health Assessment\nto get IHL Score',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                        ),
                        child: const Text(
                          'Proceed Now',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          Navigator.of(context).pushNamed(Routes.Survey, arguments: false);
                        },
                      ),
                    ),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'Try later',
                        style: TextStyle(
                            fontSize: ScUtil().setSp(14),
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              );
            }) ??
        false;
  }

  Widget _buildInfoCard(context) {
    return Column(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.only(top: 5, left: 5, right: 5),
          child: Card(
            elevation: 5.0,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.only(top: 16.0, bottom: 16.0, right: 5.0, left: 5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'IHL score',
                        style: TextStyle(
                            fontSize: ScUtil().setSp(16),
                            color: Colors.black,
                            fontWeight: FontWeight.w400),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: Row(
                          children: [
                            (s == true)
                                ? Text(
                                    score,
                                    style: TextStyle(
                                        fontSize: ScUtil().setSp(14),
                                        color: AppColors.primaryColor,
                                        fontWeight: FontWeight.w600),
                                  )
                                : InkWell(
                                    onTap: () {
                                      _survey(context);
                                    },
                                    child: const Icon(
                                      Icons.info,
                                      color: AppColors.primaryColor,
                                      size: 18,
                                    ),
                                  ),
                            const SizedBox(width: 2),
                            (s == true)
                                ? const Icon(
                                    FontAwesomeIcons.trophy,
                                    color: AppColors.primaryColor,
                                    size: 14,
                                  )
                                : Container(),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: <Widget>[
                      Text(
                        'Height',
                        style: TextStyle(
                            fontSize: ScUtil().setSp(16),
                            color: Colors.black,
                            fontWeight: FontWeight.w400),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: InkWell(
                          onTap: () {
                            if (mounted) {
                              setState(() {
                                feet = !feet;
                              });
                            }
                          },
                          child: Text(
                            feet == false ? '$height Cms' : heightft(),
                            style: TextStyle(
                                fontSize: ScUtil().setSp(14),
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: <Widget>[
                      Text(
                        'Weight',
                        style: TextStyle(
                            fontSize: ScUtil().setSp(16),
                            color: Colors.black,
                            fontWeight: FontWeight.w400),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: Text(
                          weight == ''
                              ? weightfromvitalsData == ''
                                  ? '-'
                                  : '$weightfromvitalsData Kgs'
                              : '$weight Kgs',
                          style: TextStyle(
                              fontSize: ScUtil().setSp(14),
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppversionCard(context) {
    return Column(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.only(top: 5, left: 5, right: 5),
          child: Card(
            elevation: 5.0,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.only(top: 6.0, bottom: 6.0, right: 3.0, left: 3.0),
              child: snapValue == null
                  ? Row(
                      children: [
                        Icon(
                          Icons.phone_android_rounded,
                          color: AppColors.myApp,
                        ),
                        Shimmer.fromColors(
                            direction: ShimmerDirection.ltr,
                            period: const Duration(seconds: 2),
                            baseColor: Colors.white,
                            highlightColor: AppColors.primaryAccentColor.withOpacity(0.2),
                            child: Container(
                                margin: EdgeInsets.all(8),
                                width: 50.w,
                                height: 50.w / 5,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text('Hello'))),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Icon(
                          Icons.phone_android_rounded,
                          color: AppColors.myApp,
                        ),
                        Column(
                          children: [
                            Text(
                              "Version ${snapValue.currentVersion}",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: ScUtil().setSp(14),
                                  color: Colors.grey,
                                  letterSpacing: 0.7,
                                  fontWeight: FontWeight.w600),
                            ),
                            snapValue.canUpdate
                                ? Text(
                                    "App Update Available",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 13.sp,
                                        color: Colors.black,
                                        letterSpacing: 0.7,
                                        fontWeight: FontWeight.w800),
                                  )
                                : const SizedBox(),
                          ],
                        ),
                        snapValue.canUpdate
                            ? Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ElevatedButton(
                                  onPressed: () async {
                                    Uri url = Uri.parse(snapValue.appURL);
                                    await launchUrl(
                                      url,
                                      mode: LaunchMode.externalApplication,
                                    );
                                  },
                                  style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty.all<Color>(
                                          AppColors.primaryAccentColor)),
                                  child: Text(
                                    "UPDATE",
                                    style: TextStyle(
                                        fontSize: 14.sp,
                                        color: Colors.white,
                                        letterSpacing: 0.7,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                              )
                            : const SizedBox(),
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

class PersonalProfileDetailsCard extends StatefulWidget {
  const PersonalProfileDetailsCard({Key key}) : super(key: key);

  @override
  _PersonalProfileDetailsCardState createState() => _PersonalProfileDetailsCardState();
}

class _PersonalProfileDetailsCardState extends State<PersonalProfileDetailsCard> {
  bool isloading = true;
  bool isChanging = false;
  bool s;
  String firstName = '';
  String lastName = '';
  String email = '';
  String mobileNumber = '';
  String emailOld = '';
  String mobileNumberOld = '';
  String gender = '';
  String address = '';
  String pincode = '';
  String area = '';
  String state = '';
  String city = '';
  String dob = '';
  String height = '';
  String weight = '';
  String weightfromvitalsData = '';
  String score = '';
  String userAffiliation = '';
  bool emailFixed = true;
  bool showWeight = true;
  bool feet = false;

  Future<void> getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Object data = prefs.get(SPKeys.userData);
    double finalWeight = prefs.getDouble(SPKeys.weight);
    finalWeight = ((finalWeight ?? 0 * 100.0).toInt()) / 100;
    weightfromvitalsData = finalWeight.toString();
    data = data == null || data == '' ? '{"User":{}}' : data;
    Map res = jsonDecode(data);
    res['User']['user_score'] ??= {};
    res['User']['user_score']['T'] ??= 'N/A';
    score = res['User']['user_score']['T'].toString();
    s = prefs.getBool('allAns');
    firstName = res['User']['firstName'];
    firstName ??= '';
    lastName = res['User']['lastName'];
    lastName ??= '';
    prefs.setString('name', '$firstName $lastName');
    email = res['User']['email'];
    email ??= '';
    emailOld = email;
    mobileNumber = res['User']['mobileNumber'];
    mobileNumber ??= '';
    prefs.setString('mobile', mobileNumber);
    mobileNumberOld = mobileNumber;
    dob = res['User']['dateOfBirth'].toString();
    dob = dob == 'null' ? '' : dob;
    dob ??= '01-01-2000';
    address = res['User']['address'].toString();
    address = address == 'null' ? 'Please Add Address to Book an Appointment' : address;
    area = res['User']['area'].toString();
    area = area == 'null' ? '' : area;
    city = res['User']['city'].toString();
    city = city == 'null' ? '' : city;
    state = res['User']['state'].toString();
    state = state == 'null' ? '' : state;
    pincode = res['User']['pincode'].toString();
    pincode = pincode == 'null' ? '' : pincode;
    gender = res['User']['gender'];
    gender ??= 'o';
    if (res['User']['heightMeters'] is num) {
      height = (res['User']['heightMeters'] * 100).toInt().toString();
    }
    height ??= '';
    if (weightfromvitalsData == null || weightfromvitalsData == 'null') {
      weightfromvitalsData = '';
    }
    if (res.length == 3) {
      if (res['LastCheckin']['weightKG'] != null) {
        weight = ((((res['LastCheckin']['weightKG']) * 100.0).toInt()) / 100).toString() ?? "";
      }
    }
    if (weight == null || weight == '') {
      weight = res['User']['userInputWeightInKG'];
    }

    weight = weight == 'null' ? '' : weight;
    weight ??= '';
    userAffiliation = res['User']['affiliate'].toString();
    userAffiliation = AppTexts.affiliationOp.contains(userAffiliation) ? userAffiliation : 'none';
    if (res['LastCheckin'] != null &&
        (res['LastCheckin']['weightKG'] != null || res['LastCheckin']['weightKG'] != '') &&
        res.length == 3) {
      showWeight = false;
    }
    if (email == '' || email == null) {
      emailFixed = false;
    }
    isloading = false;
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
    ScUtil.init(context, width: 360, height: 640, allowFontScaling: true);
    if (isloading) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 50),
        color: AppColors.bgColorTab,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Container(
        padding: const EdgeInsets.all(10),
        child: Card(
          child: Container(
            alignment: Alignment.topLeft,
            padding: const EdgeInsets.all(15),
            child: Column(
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      child: Row(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: MediumProfilePhoto(),
                          ),
                          Flexible(
                            child: Text(
                              camelize('$firstName $lastName'),
                              maxLines: 3,
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 22,
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildDivider(),
                    _buildInfoCard(context),
                    SizedBox(height: ScUtil().setHeight(15)),
                    ListTile(
                      leading: const Icon(
                        Icons.email,
                        color: AppColors.primaryColor,
                      ),
                      title: Text(
                        "E-Mail",
                        style: TextStyle(
                          fontSize: ScUtil().setSp(16),
                        ),
                      ),
                      subtitle: FittedBox(
                        child: Text(
                          email,
                          style: TextStyle(
                            fontSize: ScUtil().setSp(14),
                          ),
                        ),
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(
                        Icons.phone,
                        color: AppColors.primaryColor,
                      ),
                      title: Text(
                        "Phone Number",
                        style: TextStyle(
                          fontSize: ScUtil().setSp(16),
                        ),
                      ),
                      subtitle: Text(
                        mobileNumber,
                        style: TextStyle(
                          fontSize: ScUtil().setSp(14),
                        ),
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      leading: const Icon(
                        Icons.calendar_today,
                        color: AppColors.primaryColor,
                      ),
                      title: Text(
                        "Date of Birth",
                        style: TextStyle(
                          fontSize: ScUtil().setSp(16),
                        ),
                      ),
                      subtitle: Text(
                        dob,
                        style: TextStyle(
                          fontSize: ScUtil().setSp(14),
                        ),
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(
                        Icons.person,
                        color: AppColors.primaryColor,
                      ),
                      title: Text(
                        "Gender",
                        style: TextStyle(
                          fontSize: ScUtil().setSp(16),
                        ),
                      ),
                      subtitle: Text(
                        (gender == 'm' || gender == 'M' || gender == 'male' || gender == 'Male')
                            ? 'Male'
                            : (gender == 'f' ||
                                    gender == 'F' ||
                                    gender == 'female' ||
                                    gender == 'Female')
                                ? 'Female'
                                : 'Others',
                        style: TextStyle(
                          fontSize: ScUtil().setSp(14),
                        ),
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(
                        Icons.home,
                        color: AppColors.primaryColor,
                      ),
                      title: Text(
                        "Address",
                        style: TextStyle(
                          fontSize: ScUtil().setSp(16),
                        ),
                      ),
                      subtitle: Text(
                        "$address\n$area\n$city\n$state\n$pincode",
                        style: TextStyle(
                          fontSize: ScUtil().setSp(14),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ));
  }

  String heightft() {
    double h = double.tryParse(height);
    if (h == null) {
      return '';
    }
    return cmToFeetInch(h.toInt());
  }

  Future<bool> _survey(BuildContext context) {
    return showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Column(
                  children: [
                    const Text(
                      'Finish Health Assessment\nto get IHL Score',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                        ),
                        child: const Text(
                          'Proceed Now',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          Navigator.of(context).pushNamed(Routes.Survey, arguments: false);
                        },
                      ),
                    ),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'Try later',
                        style: TextStyle(
                            fontSize: ScUtil().setSp(14),
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              );
            }) ??
        false;
  }

  Widget _buildInfoCard(context) {
    return Column(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.only(top: 5, left: 5, right: 5),
          child: Card(
            elevation: 5.0,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.only(top: 16.0, bottom: 16.0, right: 5.0, left: 5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'IHL score',
                        style: TextStyle(
                            fontSize: ScUtil().setSp(16),
                            color: Colors.black,
                            fontWeight: FontWeight.w400),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: Row(
                          children: [
                            (s == true)
                                ? Text(
                                    score,
                                    style: TextStyle(
                                        fontSize: ScUtil().setSp(14),
                                        color: AppColors.primaryColor,
                                        fontWeight: FontWeight.w600),
                                  )
                                : InkWell(
                                    onTap: () {
                                      _survey(context);
                                    },
                                    child: const Icon(
                                      Icons.info,
                                      color: AppColors.primaryColor,
                                      size: 18,
                                    ),
                                  ),
                            const SizedBox(width: 2),
                            (s == true)
                                ? const Icon(
                                    FontAwesomeIcons.trophy,
                                    color: AppColors.primaryColor,
                                    size: 14,
                                  )
                                : Container(),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: <Widget>[
                      Text(
                        'Height',
                        style: TextStyle(
                            fontSize: ScUtil().setSp(16),
                            color: Colors.black,
                            fontWeight: FontWeight.w400),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: InkWell(
                          onTap: () {
                            if (mounted) {
                              setState(() {
                                feet = !feet;
                              });
                            }
                          },
                          child: Text(
                            feet == false ? '$height Cms' : heightft(),
                            style: TextStyle(
                                fontSize: ScUtil().setSp(14),
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: <Widget>[
                      Text(
                        'Weight',
                        style: TextStyle(
                            fontSize: ScUtil().setSp(16),
                            color: Colors.black,
                            fontWeight: FontWeight.w400),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: Text(
                          weight == ''
                              ? weightfromvitalsData == ''
                                  ? '-'
                                  : '$weightfromvitalsData Kgs'
                              : '$weight Kgs',
                          style: TextStyle(
                              fontSize: ScUtil().setSp(14),
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Container _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 8.0,
      ),
      width: double.infinity,
      height: 1.0,
      color: Colors.grey.shade300,
    );
  }
}
