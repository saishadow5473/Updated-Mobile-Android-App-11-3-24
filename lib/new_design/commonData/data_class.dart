import 'package:flutter/material.dart';

class ProfileDataModel {
  ProfileDataModel(
      {this.displayPicture,
      @required this.firstName,
      @required this.lastName,
      @required this.uid,
      @required this.email,
      this.mobileNumber,
      this.gender,
      this.height,
      this.weight,
      this.dob,
      this.address,
      this.city,
      this.area,
      this.state,
      this.pincode});
  String displayPicture;
  String firstName;
  String lastName;
  String uid;
  String email;
  String mobileNumber;
  String gender;
  double height;
  double weight;
  DateTime dob;
  String address;
  String city;
  String area;
  String state;
  String pincode;
}
