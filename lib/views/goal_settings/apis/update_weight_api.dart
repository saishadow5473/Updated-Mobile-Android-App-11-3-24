import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:ihl/constants/spKeys.dart';
import 'package:ihl/models/checkInternet.dart';
import 'package:ihl/repositories/api_repository.dart';
import 'package:ihl/repositories/getuserData.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpdateWeight {
  // bool isloading = true;
  // bool isChanging = false;
  // final _formKey = GlobalKey<FormState>();
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
  static GetData _updateData = GetData();
  bool showWeight = true;
  static Apirepository _apiRepository = Apirepository();

  Future<void> getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var data = prefs.get(SPKeys.userData);
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
    // weight ??= '';
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
  }

  updateWeight(dynamic newWeight,bool fromWeight) async {
    await getData();
    var returnValue;
    weight = newWeight;
    if (!validate()) {
      returnValue = false;
      return false;
    }
    // FocusScope.of(context).unfocus();
    bool connection = await checkInternet();
    // if (connection == false) {
    //   // SnackBar snackBar = SnackBar(
    //   //   content:
    //   //   Text('Failed to connect to internet, please check your connection'),
    //   //   backgroundColor: Colors.amber,
    //   // );
    //   // ScaffoldMessenger.of(context).showSnackBar(snackBar);
    //   // if (this.mounted) {
    //   //   setState(() {
    //   //     isChanging = false;
    //   //   });
    //   // }
    //   return null;
    // }
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(
    //     backgroundColor: Colors.amber,
    //     content: Text('Checking information........'),
    //   ),
    // );
    String heightM = (double.tryParse(height) / 100).toString();
    try {
      // bool mobilEMail =  connection;
      if (connection == true) {
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
            .then((value) async {
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(
          //     backgroundColor: Colors.amber,
          //     content: Text('Updating profile..'),
          //   ),
          // );
          //Uncomment the lines to add affiliation register
          //***these are important dont remove any commented line in this page
          /*String updatedAffiliation = await _updateData.updateAffiliation(
              affiliationUniqueName,
              userAffiliation,
              emailAffiliateController.text,
              mobileAffiliateController.text,
              "DE003");*/
          bool resp = await _updateData.uptoUserInfoDate(fromWeight: fromWeight);
          if (resp == true) {
            //&& updatedAffiliation == "AffiliationSuccessful") {
            // ScaffoldMessenger.of(context).showSnackBar(
            //   SnackBar(
            //     backgroundColor: AppColors.primaryAccentColor,
            //     content: Text('Profile updated Successfully!!'),
            //   ),
            // );
            // if (this.mounted) {
            //   setState(() {
            //     isChanging = false;
            //     makeEmailMobileControllerVisible = false;
            //   });
            // }
            returnValue = true;
            return true;

            ///getData();
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
            returnValue = false;
            return false;
          }
        }).catchError((e) {
          // if (this.mounted) {
          //   setState(() {
          //     isChanging = false;
          //   });
          // }
          ///breaker
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(
          //     backgroundColor: AppColors.primaryAccentColor,
          //     content: Text('Failed to update'),
          //   ),
          // );
          returnValue = false;
          return false;
        });
      }
    } catch (e) {
      returnValue = false;
      return false;
    }
    return returnValue;
  }

  bool validate() {
    if (nameValidator(firstName) != null ||
        nameValidator(lastName) != null ||
        emailValidator(email) != null ||
        phoneValidator(mobileNumber) != null ||
        heightValidator(height) != null ||
        addressValidator(address) != null ||
        zipValidator(pincode) != null ||
        cityValidator(city) != null ||
        stateValidator(state) != null ||
        areaValidator(area) != null ||
        (weightValidator(weight) != null && showWeight)) {
      return true;
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
}
