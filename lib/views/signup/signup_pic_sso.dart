// import 'dart:convert';
// import 'dart:io';
// import 'dart:ui';
//
// import 'package:awesome_dialog/awesome_dialog.dart';
// import 'package:connectivity_wrapper/connectivity_wrapper.dart';
// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:ihl/constants/routes.dart';
// import 'package:ihl/repositories/api_register.dart';
// import 'package:ihl/utils/ScUtil.dart';
// import 'package:ihl/utils/SpUtil.dart';
// import 'package:ihl/utils/app_colors.dart';
// import 'package:ihl/utils/sizeConfig.dart';
// import 'package:ihl/widgets/image_picker_handler.dart';
// import 'package:ihl/widgets/offline_widget.dart';
//
// String fname, lname, email, pwd, mobile, dob, gender, height, weight, ssoToken;
//
// class SignupPicSso extends StatefulWidget {
//   @override
//   _SignupPicSsoState createState() => _SignupPicSsoState();
// }
//
// class _SignupPicSsoState extends State<SignupPicSso>
//     with TickerProviderStateMixin, ImagePickerListener {
//   http.Client _client = http.Client(); //3gb
//   int _index = 0;
//   List<String> emoji = [
//     'https://cdn.shopify.com/s/files/1/1061/1924/products/Happy_Emoji_Icon_5c9b7b25-b215-4457-922d-fef519a08b06_large.png',
//     'https://cdn.shopify.com/s/files/1/1061/1924/products/Emoji_Icon_-_Sunglasses_cool_emoji_large.png',
//     'https://cdn.shopify.com/s/files/1/1061/1924/products/Emoji_Icon_-_Smiling_large.png',
//     'https://cdn.shopify.com/s/files/1/1061/1924/products/Heart_Eyes_Emoji_2_large.png',
//     'https://cdn.shopify.com/s/files/1/1061/1924/products/Tongue_Out_Emoji_3_large.png?v=1571606093',
//     'https://cdn.shopify.com/s/files/1/1061/1924/products/Smiling_With_Sweat_Emoji_2_03db33ba-4c3b-4e9e-8f29-8bac5b9b9166_large.png'
//   ];
//   List<Object> myList = ['😁', '😎', '😃', '😍', '😛', '😅'];
//   File _image;
//   AnimationController _controller;
//   ImagePickerHandler imagePicker;
//   var userReg;
//   var userRegister;
//   bool isloading;
//   bool done;
//
//   void _initAsync() async {
//     await SpUtil.getInstance();
//   }
//
//   Future<String> networkImageToBase64(String imageUrl) async {
//     http.Response response = await _client.get(Uri.parse(imageUrl));
//     final bytes = response?.bodyBytes;
//     return (bytes != null ? base64Encode(bytes) : null);
//   }
//
//   void _imgupload(File image) async {
//     if (image != null) {
//       final bytes = await File(image.path).readAsBytes();
//       String img64 = base64Encode(bytes);
//       try {
//         showDialog(
//           context: context,
//           barrierDismissible: false,
//           builder: (BuildContext context) {
//             return Dialog(
//               child: Container(
//                 height: 100,
//                 child: Center(
//                   child: new Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       new CircularProgressIndicator(),
//                       SizedBox(
//                         width: 10,
//                       ),
//                       new Text("Processing... Please wait"),
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           },
//         );
//         userRegister = await RegisterUserWithPic().registerUser(
//             firstName: fname,
//             lastName: lname,
//             email: email,
//             password: pwd,
//             mobileNumber: mobile,
//             gender: gender,
//             dob: dob,
//             height: height,
//             weight: weight,
//             profilepic: img64,
//             isSso: true,
//             ssoToken: ssoToken);
//         if (userRegister == 'User Registration Failed') {
//           Navigator.pop(context);
//           AwesomeDialog(
//               context: context,
//               animType: AnimType.TOPSLIDE,
//               headerAnimationLoop: false,
//               dialogType: DialogType.ERROR,
//               dismissOnTouchOutside: true,
//               title: 'Failed!',
//               desc: 'Registration failed\nTry Again!',
//               onDissmissCallback: () {
//                 debugPrint('Dialog Dissmiss from callback');
//               }).show();
//         } else if (userRegister == 'Photo upload Failed') {
//           Navigator.pop(context);
//           AwesomeDialog(
//               context: context,
//               animType: AnimType.TOPSLIDE,
//               headerAnimationLoop: false,
//               dialogType: DialogType.INFO,
//               dismissOnTouchOutside: true,
//               title: 'Profile Picture upload Failed!',
//               desc:
//                   'Your Registration was Success!\nBut Profile Picture wasn\'t Uploaded!\nTry Again in Profile section!',
//               btnOkText: 'Continue',
//               btnOkColor: Color(0xFF19a9e5),
//               btnOkOnPress: () {
//                 Navigator.of(context).pushReplacementNamed(Routes.SProceed);
//                 debugPrint('OnClcik');
//               },
//               onDissmissCallback: () {
//                 debugPrint('Dialog Dissmiss from callback');
//               }).show();
//         } else {
//           Navigator.pop(context);
//           AwesomeDialog(
//               context: context,
//               animType: AnimType.TOPSLIDE,
//               headerAnimationLoop: true,
//               dialogType: DialogType.SUCCES,
//               dismissOnTouchOutside: false,
//               title: 'Success!',
//               desc: 'Your Profile was successfully registered in IHL',
//               btnOkOnPress: () {
//                 Navigator.of(context).pushReplacementNamed(Routes.SProceed);
//                 debugPrint('OnClcik');
//               },
//               btnOkText: 'Proceed',
//               btnOkIcon: Icons.check_circle,
//               onDissmissCallback: () {
//                 debugPrint('Dialog Dissmiss from callback');
//               }).show();
//         }
//       } catch (error) {
//         print(error);
//       }
//     } else if (image == null) {
//       final img64 = await networkImageToBase64(emoji[_index]);
//       try {
//         showDialog(
//           context: context,
//           barrierDismissible: false,
//           builder: (BuildContext context) {
//             return Dialog(
//               child: Container(
//                 height: 100,
//                 child: Center(
//                   child: new Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       new CircularProgressIndicator(),
//                       SizedBox(
//                         width: 10,
//                       ),
//                       new Text("Processing... Please wait"),
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           },
//         );
//         userRegister = await RegisterUserWithPic().registerUser(
//             firstName: fname,
//             lastName: lname,
//             email: email,
//             password: pwd,
//             mobileNumber: mobile,
//             gender: gender,
//             dob: dob,
//             height: height,
//             weight: weight,
//             profilepic: img64,
//             isSso: true,
//             ssoToken: ssoToken);
//         if (userRegister == 'User Registration Failed') {
//           Navigator.pop(context);
//           AwesomeDialog(
//               context: context,
//               animType: AnimType.TOPSLIDE,
//               headerAnimationLoop: false,
//               dialogType: DialogType.ERROR,
//               dismissOnTouchOutside: true,
//               title: 'Failed!',
//               desc: 'Registration failed\nTry Again!',
//               onDissmissCallback: () {
//                 debugPrint('Dialog Dissmiss from callback');
//               }).show();
//         } else if (userRegister == 'Photo upload Failed') {
//           Navigator.pop(context);
//           AwesomeDialog(
//               context: context,
//               animType: AnimType.TOPSLIDE,
//               headerAnimationLoop: false,
//               dialogType: DialogType.INFO,
//               dismissOnTouchOutside: true,
//               title: 'Profile Picture upload Failed!',
//               desc:
//                   'Your Registration was Success!\nBut Profile Picture wasn\'t Uploaded!\nTry Again in Profile section!',
//               btnOkText: 'Continue',
//               btnOkColor: Color(0xFF19a9e5),
//               btnOkOnPress: () {
//                 Navigator.of(context).pushReplacementNamed(Routes.SProceed);
//                 debugPrint('OnClcik');
//               },
//               onDissmissCallback: () {
//                 debugPrint('Dialog Dissmiss from callback');
//               }).show();
//         } else {
//           Navigator.pop(context);
//           AwesomeDialog(
//               context: context,
//               animType: AnimType.TOPSLIDE,
//               headerAnimationLoop: true,
//               dialogType: DialogType.SUCCES,
//               dismissOnTouchOutside: false,
//               title: 'Success!',
//               desc: 'Your Profile was successfully registered in IHL',
//               btnOkOnPress: () {
//                 Navigator.of(context).pushReplacementNamed(Routes.SProceed);
//                 debugPrint('OnClcik');
//               },
//               btnOkText: 'Proceed',
//               btnOkIcon: Icons.check_circle,
//               onDissmissCallback: () {
//                 debugPrint('Dialog Dissmiss from callback');
//               }).show();
//         }
//       } catch (error) {
//         print(error);
//       }
//     } else {
//       try {
//         showDialog(
//           context: context,
//           barrierDismissible: false,
//           builder: (BuildContext context) {
//             return Dialog(
//               child: Container(
//                 height: 100,
//                 child: Center(
//                   child: new Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       new CircularProgressIndicator(),
//                       SizedBox(
//                         width: 10,
//                       ),
//                       new Text("Processing... Please wait"),
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           },
//         );
//         userReg = await RegisterUser().registerUser(
//           firstName: fname,
//           lastName: lname,
//           email: email,
//           password: pwd,
//           mobileNumber: mobile,
//           gender: gender,
//           dob: dob,
//           height: height,
//           weight: weight,
//           isSso: true,
//           ssoToken: ssoToken,
//         );
//         if (userReg == 'User Registration Failed') {
//           Navigator.pop(context);
//           AwesomeDialog(
//               context: context,
//               animType: AnimType.TOPSLIDE,
//               headerAnimationLoop: false,
//               dialogType: DialogType.ERROR,
//               dismissOnTouchOutside: true,
//               title: 'Failed!',
//               desc: 'Registration failed\nTry Again!',
//               onDissmissCallback: () {
//                 debugPrint('Dialog Dissmiss from callback');
//               }).show();
//         } else {
//           Navigator.pop(context);
//           AwesomeDialog(
//               context: context,
//               animType: AnimType.TOPSLIDE,
//               headerAnimationLoop: true,
//               dialogType: DialogType.SUCCES,
//               dismissOnTouchOutside: false,
//               title: 'Success!',
//               desc: 'Your Profile was successfully registered in IHL',
//               btnOkOnPress: () {
//                 Navigator.of(context).pushReplacementNamed(Routes.SProceed);
//                 debugPrint('OnClcik');
//               },
//               btnOkText: 'Proceed',
//               btnOkIcon: Icons.check_circle,
//               onDissmissCallback: () {
//                 debugPrint('Dialog Dissmiss from callback');
//               }).show();
//         }
//       } catch (error) {
//         print(error);
//       }
//     }
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     _initAsync();
//     fname = SpUtil.getString('fname');
//     lname = SpUtil.getString('lname');
//     email = SpUtil.getString('email');
//     pwd = SpUtil.getString('pwd');
//     mobile = SpUtil.getString('mob').toString();
//     dob = SpUtil.getString('dob');
//     gender = SpUtil.getString('gender');
//     height = SpUtil.getString('height');
//     weight = SpUtil.getString('weight');
//     ssoToken = SpUtil.getString('sso_token');
//
//     _controller = new AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 500),
//     );
//
//     imagePicker = new ImagePickerHandler(this, _controller);
//     imagePicker.init();
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     ScUtil.init(context, width: 360, height: 640, allowFontScaling: false);
//     Widget _customButton() {
//       return Container(
//         height: 60,
//         child: GestureDetector(
//           onTap: () {
//             _imgupload(_image);
//           },
//           child: Container(
//             decoration: BoxDecoration(
//               color: Color(0xFF19a9e5),
//               borderRadius: BorderRadius.circular(20.0),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: <Widget>[
//                 Center(
//                   child: Text(
//                     'Sign Up',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                         color: Color.fromRGBO(255, 255, 255, 1),
//                         fontFamily: 'Poppins',
//                         fontSize: 16,
//                         letterSpacing: 0.2,
//                         fontWeight: FontWeight.normal,
//                         height: 1),
//                   ),
//                 )
//               ],
//             ),
//           ),
//         ),
//       );
//     }
//
//     return SafeArea(
//       top: true,
//       child: ConnectivityWidgetWrapper(
//         disableInteraction: true,
//         offlineWidget: OfflineWidget(),
//         child: Scaffold(
//           appBar: AppBar(
//             backgroundColor: Colors.transparent,
//             elevation: 0.0,
//             title: Padding(
//               padding: const EdgeInsets.only(left: 20),
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(10),
//                 child: Container(
//                   height: 5,
//                   child: LinearProgressIndicator(
//                     value: 1, // percent filled
//                     backgroundColor: Color(0xffDBEEFC),
//                   ),
//                 ),
//               ),
//             ),
//             leading: IconButton(
//               icon: Icon(Icons.arrow_back_ios),
//               onPressed: () => Navigator.of(context).pushNamed(Routes.Sweight),
//               // Navigator.of(context).pushNamed(Routes.Aff),
//               color: Colors.black,
//             ),
//             actions: <Widget>[
//               TextButton(
//                 onPressed: () =>
//                     Navigator.of(context).pushNamed(Routes.SProceed),
//                 child: Text("Next",
//                     style: TextStyle(
//                       fontFamily: 'Poppins',
//                       fontWeight: FontWeight.bold,
//                       fontSize: ScUtil().setSp(16),
//                     )),
//                 style: TextButton.styleFrom(
//                   textStyle: TextStyle(
//                     color: Color(0xFF19a9e5),
//                   ),
//                   shape:
//                       CircleBorder(side: BorderSide(color: Colors.transparent)),
//                 ),
//               ),
//             ],
//           ),
//           backgroundColor: Color(0xffF4F6FA),
//           body: Container(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topRight,
//                 end: Alignment.bottomLeft,
//                 colors: [
//                   Color.fromRGBO(244, 246, 250, 1),
//                   Color.fromRGBO(255, 255, 255, 1)
//                 ],
//               ),
//             ),
//             width: MediaQuery.of(context).size.width,
//             child: SingleChildScrollView(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: <Widget>[
//                   SizedBox(
//                     height: 5.0,
//                   ),
//                   Text(
//                     'One more step . . .',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                         color: Color(0xFF19a9e5),
//                         fontFamily: 'Poppins',
//                         fontSize: ScUtil().setSp(12),
//                         letterSpacing: 1.5,
//                         fontWeight: FontWeight.bold,
//                         height: 1.16),
//                   ),
//                   SizedBox(
//                     height: 6 * SizeConfig.heightMultiplier,
//                   ),
//                   Text(
//                     'Choose your\nProfile Picture',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                         color: Color.fromRGBO(109, 110, 113, 1),
//                         fontFamily: 'Poppins',
//                         fontSize: ScUtil().setSp(26),
//                         letterSpacing: 0,
//                         fontWeight: FontWeight.bold,
//                         height: 1.33),
//                   ),
//                   SizedBox(
//                     height: 3 * SizeConfig.heightMultiplier,
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.only(left: 40.0, right: 40.0),
//                     child: Text(
//                       'Customise you profile !',
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                           color: Color.fromRGBO(109, 110, 113, 1),
//                           fontFamily: 'Poppins',
//                           fontSize: ScUtil().setSp(15),
//                           letterSpacing: 0.2,
//                           fontWeight: FontWeight.normal,
//                           height: 1),
//                     ),
//                   ),
//                   SizedBox(
//                     height: 4 * SizeConfig.heightMultiplier,
//                   ),
//                   _image != null
//                       ? Stack(children: <Widget>[
//                           CircleAvatar(
//                             radius: 80,
//                             backgroundColor: Color(0xFF19a9e5),
//                             child: CircleAvatar(
//                               radius: 75,
//                               backgroundImage: FileImage(_image),
//                             ),
//                           ),
//                           Positioned(
//                               left: 110,
//                               top: 0,
//                               child: ClipOval(
//                                 child: Material(
//                                   elevation: 6,
//                                   color: Colors.white, // button color
//                                   child: InkWell(
//                                       splashColor: Colors.red, // inkwell color
//                                       child: SizedBox(
//                                           child: Icon(
//                                         Icons.cancel,
//                                         size: 36,
//                                         color: Colors.red,
//                                       )),
//                                       onTap: () => {
//                                             if (this.mounted)
//                                               {
//                                                 setState(() {
//                                                   this._image = null;
//                                                 }),
//                                               },
//                                           }),
//                                 ),
//                               ))
//                         ])
//                       : SizedBox(
//                           height: 150,
//                           width: 300, // card height
//                           child: PageView.builder(
//                             itemCount: myList.length,
//                             controller: PageController(viewportFraction: 0.5),
//                             onPageChanged: (int index) =>
//                                 setState(() => _index = index),
//                             itemBuilder: (_, int index) {
//                               return Transform.scale(
//                                 scale: index == _index ? 1 : 0.8,
//                                 child: Card(
//                                   color: index == _index
//                                       ? Color(0xFF19a9e5)
//                                       : Colors.white,
//                                   elevation: 6,
//                                   shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(20)),
//                                   child: Center(
//                                     child: Text(
//                                       myList[index],
//                                       style: TextStyle(fontSize: 32),
//                                     ),
//                                   ),
//                                 ),
//                               );
//                             },
//                           ),
//                         ),
//                   SizedBox(height: 4 * SizeConfig.heightMultiplier),
//                   _image != null
//                       ? RichText(
//                           text: TextSpan(
//                           text: 'Change Picture',
//                           style: TextStyle(
//                             color: AppColors.primaryColor,
//                             fontSize: ScUtil().setSp(16),
//                             fontFamily: 'Poppins',
//                             fontWeight: FontWeight.w600,
//                           ),
//                           recognizer: TapGestureRecognizer()
//                             ..onTap = () => imagePicker.showDialog(context),
//                         ))
//                       : RichText(
//                           text: TextSpan(
//                             children: [
//                               TextSpan(
//                                 text: 'Or Upload Custom Picture',
//                                 style: TextStyle(
//                                   color: AppColors.primaryColor,
//                                   fontSize: ScUtil().setSp(16),
//                                   fontFamily: 'Poppins',
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                                 recognizer: TapGestureRecognizer()
//                                   ..onTap =
//                                       () => imagePicker.showDialog(context),
//                               ),
//                             ],
//                           ),
//                         ),
//                   SizedBox(
//                     height: 4 * SizeConfig.heightMultiplier,
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.only(left: 50.0, right: 50.0),
//                     child: Center(
//                       child: _customButton(),
//                     ),
//                   ),
//                   SizedBox(
//                     height: 2 * SizeConfig.heightMultiplier,
//                   ),
//                   RichText(
//                       text: TextSpan(
//                     text: 'Skip and Sign Up!',
//                     style: TextStyle(
//                       color: AppColors.primaryColor,
//                       fontSize: ScUtil().setSp(16),
//                       fontFamily: 'Poppins',
//                       fontWeight: FontWeight.w600,
//                     ),
//                     recognizer: TapGestureRecognizer()
//                       ..onTap = () async {
//                         showDialog(
//                           context: context,
//                           barrierDismissible: false,
//                           builder: (BuildContext context) {
//                             return Dialog(
//                               child: Container(
//                                 height: 100,
//                                 child: Center(
//                                   child: new Row(
//                                     mainAxisSize: MainAxisSize.min,
//                                     children: [
//                                       new CircularProgressIndicator(),
//                                       SizedBox(
//                                         width: 10,
//                                       ),
//                                       new Text("Processing... Please wait"),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             );
//                           },
//                         );
//                         userReg = await RegisterUser().registerUser(
//                             firstName: fname,
//                             lastName: lname,
//                             email: email,
//                             password: pwd,
//                             mobileNumber: mobile,
//                             gender: gender,
//                             dob: dob,
//                             height: height,
//                             weight: weight,
//                             isSso: true,
//                             ssoToken: ssoToken);
//                         if (userReg == 'User Registration Failed') {
//                           Navigator.pop(context);
//                           AwesomeDialog(
//                               context: context,
//                               animType: AnimType.TOPSLIDE,
//                               headerAnimationLoop: false,
//                               dialogType: DialogType.ERROR,
//                               dismissOnTouchOutside: true,
//                               title: 'Failed!',
//                               desc: 'Registration failed\nTry Again!',
//                               onDissmissCallback: () {
//                                 debugPrint('Dialog Dissmiss from callback');
//                               }).show();
//                         } else {
//                           Navigator.pop(context);
//                           AwesomeDialog(
//                               context: context,
//                               animType: AnimType.TOPSLIDE,
//                               headerAnimationLoop: true,
//                               dialogType: DialogType.SUCCES,
//                               dismissOnTouchOutside: false,
//                               title: 'Success!',
//                               desc:
//                                   'Your Profile was successfully registered in IHL',
//                               btnOkOnPress: () {
//                                 Navigator.of(context)
//                                     .pushReplacementNamed(Routes.SProceed);
//                                 debugPrint('OnClcik');
//                               },
//                               btnOkText: 'Proceed',
//                               btnOkIcon: Icons.check_circle,
//                               onDissmissCallback: () {
//                                 debugPrint('Dialog Dissmiss from callback');
//                               }).show();
//                         }
//                       },
//                   )),
//                   SizedBox(
//                     height: 4 * SizeConfig.heightMultiplier,
//                   ),
//                   Text(
//                     'By Signing Up,\n You Accept the Terms and Conditions of IHL Pvt. Ltd',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                         color: Colors.grey[800],
//                         fontSize: ScUtil().setSp(10),
//                         letterSpacing: 1.5,
//                         fontWeight: FontWeight.normal,
//                         height: 1.1),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   @override
//   userImage(File _image) {
//     if (this.mounted) {
//       setState(() {
//         this._image = _image;
//       });
//     }
//   }
// }

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../constants/routes.dart';
import '../../new_design/presentation/pages/profile/updatePhoto.dart';
import '../../repositories/api_register.dart';
import '../../utils/ScUtil.dart';
import '../../utils/SpUtil.dart';
import '../../utils/app_colors.dart';
import '../../utils/sizeConfig.dart';
import '../../widgets/image_picker_handler.dart';
import '../../widgets/offline_widget.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../abha/networks/network_calls_abha.dart';
import '../../abha/views/mobile_number_link.dart';

String fname, lname, email, pwd, mobile, dob, gender, height, weight, ssoToken;

class SignupPicSso extends StatefulWidget {
  const SignupPicSso({Key key}) : super(key: key);

  @override
  _SignupPicSsoState createState() => _SignupPicSsoState();
}

class _SignupPicSsoState extends State<SignupPicSso>
    with TickerProviderStateMixin, ImagePickerListener {
  final http.Client _client = http.Client(); //3gb
  int _index = 0;
  List<String> emoji = [
    'https://cdn.shopify.com/s/files/1/1061/1924/products/Happy_Emoji_Icon_5c9b7b25-b215-4457-922d-fef519a08b06_large.png',
    'https://cdn.shopify.com/s/files/1/1061/1924/products/Emoji_Icon_-_Sunglasses_cool_emoji_large.png',
    'https://cdn.shopify.com/s/files/1/1061/1924/products/Emoji_Icon_-_Smiling_large.png',
    'https://cdn.shopify.com/s/files/1/1061/1924/products/Heart_Eyes_Emoji_2_large.png',
    'https://cdn.shopify.com/s/files/1/1061/1924/products/Tongue_Out_Emoji_3_large.png?v=1571606093',
    'https://cdn.shopify.com/s/files/1/1061/1924/products/Smiling_With_Sweat_Emoji_2_03db33ba-4c3b-4e9e-8f29-8bac5b9b9166_large.png'
  ];
  List<Object> myList = ['😁', '😎', '😃', '😍', '😛', '😅'];
  File _image;
  AnimationController _controller;
  ImagePickerHandler imagePicker;
  var userReg;
  var userRegister;
  bool isloading;
  bool done;
  bool abhaLoading = false;
  void _initAsync() async {
    await SpUtil.getInstance();
  }

  Future<String> networkImageToBase64(String imageUrl) async {
    http.Response response = await _client.get(Uri.parse(imageUrl));
    final Uint8List bytes = response?.bodyBytes;
    return (bytes != null ? base64Encode(bytes) : null);
  }

  void _imgupload(File image) async {
    if (image != null) {
      final Uint8List bytes = await File(image.path).readAsBytes();
      String img64 = base64Encode(bytes);
      try {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return Dialog(
              child: SizedBox(
                height: 100,
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(
                        width: 10,
                      ),
                      const Text("Processing... Please wait"),
                    ],
                  ),
                ),
              ),
            );
          },
        );
        userRegister = await RegisterUserWithPic().registerUser(
            firstName: fname,
            lastName: lname,
            email: email,
            password: pwd,
            // mobileNumber: mobile,
            // gender: gender,
            // dob: dob,
            // height: height,
            // weight: weight,
            // profilepic: img64,
            isSso: true,
            ssoToken: ssoToken);
        if (userRegister == 'User Registration Failed') {
          Navigator.pop(context);
          AwesomeDialog(
              context: context,
              animType: AnimType.TOPSLIDE,
              headerAnimationLoop: false,
              dialogType: DialogType.ERROR,
              dismissOnTouchOutside: true,
              title: 'Failed!',
              desc: 'Registration failed\nTry Again',
              onDismissCallback: (_) {
                debugPrint('Dialog Dissmiss from callback');
              }).show();
        } else if (userRegister == 'Photo upload Failed') {
          Navigator.pop(context);
          AwesomeDialog(
              context: context,
              animType: AnimType.TOPSLIDE,
              headerAnimationLoop: false,
              dialogType: DialogType.INFO,
              dismissOnTouchOutside: true,
              title: 'Unable to upload profile picture. Please try again.',
              desc:
                  'Your Registration was Success!\nBut Profile Picture wasn\'t Uploaded!\nTry Again in Profile section!',
              btnOkText: 'Continue',
              btnOkColor: const Color(0xFF19a9e5),
              btnOkOnPress: () {
                if (abhaRegistraion && abhaSkipped == false) {
                  Get.offAll(() => MobileNumberLink());
                } else {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      Routes.SurveyProceed, (Route<dynamic> route) => false);
                  // Navigator.of(context).pushReplacementNamed(Routes.SProceed);
                }
                // Navigator.of(context).pushNamedAndRemoveUntil(
                //     Routes.SurveyProceed, (Route<dynamic> route) => false);
                // Navigator.of(context).pushReplacementNamed(Routes.SProceed);
                debugPrint('OnClcik');
              },
              onDismissCallback: (_) {
                debugPrint('Dialog Dissmiss from callback');
              }).show();
        } else {
          Navigator.pop(context);
          !abhaLoading
              ? showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return Dialog(
                      child: SizedBox(
                        height: 130,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            SizedBox(
                              height: 5,
                            ),
                            Text("Creating...your ABHA account"),
                            SizedBox(
                              height: 10,
                            ),
                            Text("Please wait......."),
                            SizedBox(
                              height: 10,
                            ),
                            Center(
                              child: CircularProgressIndicator(),
                            )
                          ],
                        ),
                      ),
                    );
                  })
              : Container();
          if (abhaSkipped == false) {
            setState(() {
              abhaLoading = false;
            });
            if (abhaRegistraion) {
              await NetworkCallsAbha().createHealthIdWithPreVerified();
            } else {
              await NetworkCallsAbha().storeAbhaDetails();
            }
            setState(() {
              abhaLoading = true;
            });
          }
          PhotoChangeNotifier.photo.value = img64.toString();
          AwesomeDialog(
              context: context,
              animType: AnimType.TOPSLIDE,
              headerAnimationLoop: true,
              dialogType: DialogType.SUCCES,
              dismissOnTouchOutside: false,
              title: 'Success!',
              desc: 'Your hCare registration has been successfully completed.',
              btnOkOnPress: () {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil(Routes.SurveyProceed, (Route<dynamic> route) => false);
                // Navigator.of(context).pushReplacementNamed(Routes.SProceed);
                debugPrint('OnClcik');
              },
              btnOkText: 'Proceed',
              btnOkIcon: Icons.check_circle,
              onDismissCallback: (_) {
                debugPrint('Dialog Dissmiss from callback');
              }).show();
        }
      } catch (error) {
        print(error);
      }
    } else if (image == null) {
      final String img64 = await networkImageToBase64(emoji[_index]);
      try {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return Dialog(
              child: SizedBox(
                height: 100,
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(
                        width: 10,
                      ),
                      Text("Processing... Please wait"),
                    ],
                  ),
                ),
              ),
            );
          },
        );
        userRegister = await RegisterUserWithPic().registerUser(
            firstName: fname,
            lastName: lname,
            email: email,
            password: pwd,
            // mobileNumber: mobile,
            // gender: gender,
            // dob: dob,
            // height: height,
            // weight: weight,
            // profilepic: img64,
            isSso: true,
            ssoToken: ssoToken);
        if (userRegister == 'User Registration Failed') {
          Navigator.pop(context);
          AwesomeDialog(
              context: context,
              animType: AnimType.TOPSLIDE,
              headerAnimationLoop: false,
              dialogType: DialogType.ERROR,
              dismissOnTouchOutside: true,
              title: 'Failed!',
              desc: 'Registration failed\nTry Again',
              onDismissCallback: (_) {
                debugPrint('Dialog Dissmiss from callback');
              }).show();
        } else if (userRegister == 'Photo upload Failed') {
          Navigator.pop(context);
          AwesomeDialog(
              context: context,
              animType: AnimType.TOPSLIDE,
              headerAnimationLoop: false,
              dialogType: DialogType.INFO,
              dismissOnTouchOutside: true,
              title: 'Unable to upload profile picture. Please try again.',
              desc:
                  'Your Registration was Success!\nBut Profile Picture wasn\'t Uploaded!\nTry Again in Profile section!',
              btnOkText: 'Continue',
              btnOkColor: const Color(0xFF19a9e5),
              btnOkOnPress: () {
                if (abhaRegistraion && abhaSkipped == false) {
                  Get.offAll(() => MobileNumberLink());
                } else {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      Routes.SurveyProceed, (Route<dynamic> route) => false);
                  // Navigator.of(context).pushReplacementNamed(Routes.SProceed);
                }
                // Navigator.of(context).pushNamedAndRemoveUntil(
                //     Routes.SurveyProceed, (Route<dynamic> route) => false);
                // Navigator.of(context).pushReplacementNamed(Routes.SProceed);
                debugPrint('OnClcik');
              },
              onDismissCallback: (_) {
                debugPrint('Dialog Dissmiss from callback');
              }).show();
        } else {
          Navigator.pop(context);
          !abhaLoading
              ? showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return Dialog(
                      child: SizedBox(
                        height: 130,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            SizedBox(
                              height: 5,
                            ),
                            Text("Creating...your ABHA account"),
                            SizedBox(
                              height: 10,
                            ),
                            Text("Please wait......."),
                            SizedBox(
                              height: 10,
                            ),
                            Center(
                              child: CircularProgressIndicator(),
                            )
                          ],
                        ),
                      ),
                    );
                  })
              : Container();
          if (abhaSkipped == false) {
            setState(() {
              abhaLoading = false;
            });
            if (abhaRegistraion) {
              await NetworkCallsAbha().createHealthIdWithPreVerified();
            } else {
              await NetworkCallsAbha().storeAbhaDetails();
            }
            setState(() {
              abhaLoading = true;
            });
          }
          PhotoChangeNotifier.photo.value = img64.toString();
          AwesomeDialog(
              context: context,
              animType: AnimType.TOPSLIDE,
              headerAnimationLoop: true,
              dialogType: DialogType.SUCCES,
              dismissOnTouchOutside: false,
              title: 'Success!',
              desc: 'Your hCare registration has been successfully completed.',
              btnOkOnPress: () {
                if (abhaRegistraion && abhaSkipped == false) {
                  Get.offAll(() => MobileNumberLink());
                } else {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      Routes.SurveyProceed, (Route<dynamic> route) => false);
                  // Navigator.of(context).pushReplacementNamed(Routes.SProceed);
                }
                // Navigator.of(context).pushNamedAndRemoveUntil(
                //     Routes.SurveyProceed, (Route<dynamic> route) => false);
                // Navigator.of(context).pushReplacementNamed(Routes.SProceed);
                debugPrint('OnClcik');
              },
              btnOkText: 'Proceed',
              btnOkIcon: Icons.check_circle,
              onDismissCallback: (_) {
                debugPrint('Dialog Dissmiss from callback');
              }).show();
        }
      } catch (error) {
        print(error);
      }
    } else {
      try {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return Dialog(
              child: SizedBox(
                height: 100,
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(
                        width: 10,
                      ),
                      const Text("Processing... Please wait"),
                    ],
                  ),
                ),
              ),
            );
          },
        );
        userReg = await RegisterUser().registerUser(
          firstName: fname,
          lastName: lname,
          email: email,
          password: pwd,
          mobileNumber: mobile,
          gender: gender,
          dob: dob,
          height: height,
          weight: weight,
          isSso: true,
          ssoToken: ssoToken,
        );
        if (userReg == 'User Registration Failed') {
          Navigator.pop(context);
          AwesomeDialog(
              context: context,
              animType: AnimType.TOPSLIDE,
              headerAnimationLoop: false,
              dialogType: DialogType.ERROR,
              dismissOnTouchOutside: true,
              title: 'Failed!',
              desc: 'Registration failed\nTry Again!',
              onDismissCallback: (_) {
                debugPrint('Dialog Dissmiss from callback');
              }).show();
        } else {
          Navigator.pop(context);
          !abhaLoading
              ? showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return Dialog(
                      child: SizedBox(
                        height: 130,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            SizedBox(
                              height: 5,
                            ),
                            Text("Creating...your ABHA account"),
                            SizedBox(
                              height: 10,
                            ),
                            Text("Please wait......."),
                            SizedBox(
                              height: 10,
                            ),
                            Center(
                              child: CircularProgressIndicator(),
                            )
                          ],
                        ),
                      ),
                    );
                  })
              : Container();
          if (abhaSkipped == false) {
            setState(() {
              abhaLoading = false;
            });
            if (abhaRegistraion && abhaSkipped == false) {
              await NetworkCallsAbha().createHealthIdWithPreVerified();
            } else {
              await NetworkCallsAbha().storeAbhaDetails();
            }
            setState(() {
              abhaLoading = true;
            });
          }

          AwesomeDialog(
              context: context,
              animType: AnimType.TOPSLIDE,
              headerAnimationLoop: true,
              dialogType: DialogType.SUCCES,
              dismissOnTouchOutside: false,
              title: 'Success!',
              desc: 'Your hCare registration has been successfully completed.',
              btnOkOnPress: () {
                if (abhaRegistraion && abhaSkipped == false) {
                  Get.offAll(() => MobileNumberLink());
                } else {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      Routes.SurveyProceed, (Route<dynamic> route) => false);
                  // Navigator.of(context).pushReplacementNamed(Routes.SProceed);
                }
                // Navigator.of(context).pushNamedAndRemoveUntil(
                //     Routes.SurveyProceed, (Route<dynamic> route) => false);
                // Navigator.of(context).pushReplacementNamed(Routes.SProceed);
                debugPrint('OnClcik');
              },
              btnOkText: 'Proceed',
              btnOkIcon: Icons.check_circle,
              onDismissCallback: (_) {
                debugPrint('Dialog Dissmiss from callback');
              }).show();
        }
      } catch (error) {
        print(error);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _initAsync();
    fname = SpUtil.getString('fname');
    lname = SpUtil.getString('lname');
    email = SpUtil.getString('email');
    pwd = SpUtil.getString('pwd');
    mobile = SpUtil.getString('mob').toString();
    dob = SpUtil.getString('dob');
    gender = SpUtil.getString('gender');
    height = SpUtil.getString('height');
    weight = SpUtil.getString('weight');
    ssoToken = SpUtil.getString('sso_token');

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    imagePicker = ImagePickerHandler(this, _controller);
    imagePicker.init();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScUtil.init(context, width: 360, height: 640, allowFontScaling: false);
    Widget _customButton() {
      return SizedBox(
        height: 60,
        child: GestureDetector(
          onTap: () {
            _imgupload(_image);
          },
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF19a9e5),
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const <Widget>[
                Center(
                  child: Text(
                    'Sign Up',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Color.fromRGBO(255, 255, 255, 1),
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        letterSpacing: 0.2,
                        fontWeight: FontWeight.normal,
                        height: 1),
                  ),
                )
              ],
            ),
          ),
        ),
      );
    }

    return SafeArea(
      top: true,
      child: ConnectivityWidgetWrapper(
        disableInteraction: true,
        offlineWidget: OfflineWidget(),
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0.0,
            title: Padding(
              padding: const EdgeInsets.only(left: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  height: 5,
                  child: const LinearProgressIndicator(
                    value: 1, // percent filled
                    backgroundColor: Color(0xffDBEEFC),
                  ),
                ),
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () => Navigator.of(context).pushNamed(Routes.Sweight),
              // Navigator.of(context).pushNamed(Routes.Aff),
              color: Colors.black,
            ),
            actions: <Widget>[
              Visibility(
                visible: false,
                replacement: SizedBox(
                  width: 10.w,
                ),
                child: TextButton(
                  onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
                      Routes.SurveyProceed, (Route<dynamic> route) => false),
                  style: TextButton.styleFrom(
                    textStyle: const TextStyle(
                      color: Color(0xFF19a9e5),
                    ),
                    shape: const CircleBorder(side: BorderSide(color: Colors.transparent)),
                  ),
                  // Navigator.of(context).pushNamed(Routes.SProceed),
                  child: Text("Next",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: ScUtil().setSp(16),
                      )),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xffF4F6FA),
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [Color.fromRGBO(244, 246, 250, 1), Color.fromRGBO(255, 255, 255, 1)],
              ),
            ),
            width: MediaQuery.of(context).size.width,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(
                    height: 5.0,
                  ),
                  Text(
                    'One more step . . .',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: const Color(0xFF19a9e5),
                        fontFamily: 'Poppins',
                        fontSize: ScUtil().setSp(12),
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.bold,
                        height: 1.16),
                  ),
                  SizedBox(
                    height: 6 * SizeConfig.heightMultiplier,
                  ),
                  Text(
                    'Choose your\nProfile Picture',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: const Color.fromRGBO(109, 110, 113, 1),
                        fontFamily: 'Poppins',
                        fontSize: ScUtil().setSp(26),
                        letterSpacing: 0,
                        fontWeight: FontWeight.bold,
                        height: 1.33),
                  ),
                  SizedBox(
                    height: 3 * SizeConfig.heightMultiplier,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 40.0, right: 40.0),
                    child: Text(
                      'Customise you profile !',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: const Color.fromRGBO(109, 110, 113, 1),
                          fontFamily: 'Poppins',
                          fontSize: ScUtil().setSp(15),
                          letterSpacing: 0.2,
                          fontWeight: FontWeight.normal,
                          height: 1),
                    ),
                  ),
                  SizedBox(
                    height: 4 * SizeConfig.heightMultiplier,
                  ),
                  _image != null
                      ? Stack(children: <Widget>[
                          CircleAvatar(
                            radius: 80,
                            backgroundColor: const Color(0xFF19a9e5),
                            child: CircleAvatar(
                              radius: 75,
                              backgroundImage: FileImage(_image),
                            ),
                          ),
                          Positioned(
                              left: 110,
                              top: 0,
                              child: ClipOval(
                                child: Material(
                                  elevation: 6,
                                  color: Colors.white, // button color
                                  child: InkWell(
                                      splashColor: Colors.red, // inkwell color
                                      child: const SizedBox(
                                          child: Icon(
                                        Icons.cancel,
                                        size: 36,
                                        color: Colors.red,
                                      )),
                                      onTap: () => {
                                            if (mounted)
                                              {
                                                setState(() {
                                                  _image = null;
                                                }),
                                              },
                                          }),
                                ),
                              ))
                        ])
                      : SizedBox(
                          height: 150,
                          width: 300, // card height
                          child: PageView.builder(
                            itemCount: myList.length,
                            controller: PageController(viewportFraction: 0.5),
                            onPageChanged: (int index) => setState(() => _index = index),
                            itemBuilder: (_, int index) {
                              return Transform.scale(
                                scale: index == _index ? 1 : 0.8,
                                child: Card(
                                  color: index == _index ? const Color(0xFF19a9e5) : Colors.white,
                                  elevation: 6,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20)),
                                  child: Center(
                                    child: Text(
                                      myList[index],
                                      style: const TextStyle(fontSize: 32),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                  SizedBox(height: 4 * SizeConfig.heightMultiplier),
                  _image != null
                      ? RichText(
                          text: TextSpan(
                          text: 'Change Picture',
                          style: TextStyle(
                            color: AppColors.primaryColor,
                            fontSize: ScUtil().setSp(16),
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => imagePicker.showDialog(context),
                        ))
                      : RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Or Upload Custom Picture',
                                style: TextStyle(
                                  color: AppColors.primaryColor,
                                  fontSize: ScUtil().setSp(16),
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w600,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () => imagePicker.showDialog(context),
                              ),
                            ],
                          ),
                        ),
                  SizedBox(
                    height: 4 * SizeConfig.heightMultiplier,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 50.0, right: 50.0),
                    child: Center(
                      child: _customButton(),
                    ),
                  ),
                  SizedBox(
                    height: 2 * SizeConfig.heightMultiplier,
                  ),
                  RichText(
                      text: TextSpan(
                    text: 'Skip and Sign Up!',
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontSize: ScUtil().setSp(16),
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () async {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            return Dialog(
                              child: SizedBox(
                                height: 100,
                                child: Center(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const CircularProgressIndicator(),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      const Text("Processing... Please wait"),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                        userReg = await RegisterUser().registerUser(
                            firstName: fname,
                            lastName: lname,
                            email: email,
                            password: pwd,
                            mobileNumber: mobile,
                            gender: gender,
                            dob: dob,
                            height: height,
                            weight: weight,
                            isSso: true,
                            ssoToken: ssoToken);
                        if (userReg == 'User Registration Failed') {
                          Navigator.pop(context);
                          AwesomeDialog(
                              context: context,
                              animType: AnimType.TOPSLIDE,
                              headerAnimationLoop: false,
                              dialogType: DialogType.ERROR,
                              dismissOnTouchOutside: true,
                              title: 'Failed!',
                              desc: 'Registration failed\nTry Again!',
                              onDismissCallback: (_) {
                                debugPrint('Dialog Dissmiss from callback');
                              }).show();
                        } else {
                          Navigator.pop(context);
                          if (abhaSkipped == false) {
                            if (abhaRegistraion && abhaSkipped == false) {
                              await NetworkCallsAbha().createHealthIdWithPreVerified();
                            } else {
                              await NetworkCallsAbha().storeAbhaDetails();
                            }
                          }

                          AwesomeDialog(
                              context: context,
                              animType: AnimType.TOPSLIDE,
                              headerAnimationLoop: true,
                              dialogType: DialogType.SUCCES,
                              dismissOnTouchOutside: false,
                              title: 'Success!',
                              desc: 'Your hCare registration has been successfully completed.',
                              btnOkOnPress: () {
                                if (abhaRegistraion && abhaSkipped == false) {
                                  Get.offAll(() => MobileNumberLink());
                                } else {
                                  Navigator.of(context).pushNamedAndRemoveUntil(
                                      Routes.SurveyProceed, (Route<dynamic> route) => false);
                                  // Navigator.of(context).pushReplacementNamed(Routes.SProceed);
                                }
                                // Navigator.of(context).pushNamedAndRemoveUntil(
                                //     Routes.SurveyProceed,
                                //     (Route<dynamic> route) => false);
                                // Navigator.of(context)
                                //     .pushReplacementNamed(Routes.SProceed);
                                debugPrint('OnClcik');
                              },
                              btnOkText: 'Proceed',
                              btnOkIcon: Icons.check_circle,
                              onDismissCallback: (_) {
                                debugPrint('Dialog Dissmiss from callback');
                              }).show();
                        }
                      },
                  )),
                  SizedBox(
                    height: 4 * SizeConfig.heightMultiplier,
                  ),
                  Text(
                    'By Signing Up,\n You Accept the Terms and Conditions of IHL Pvt. Ltd',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.grey[800],
                        fontSize: ScUtil().setSp(10),
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.normal,
                        height: 1.1),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  userImage(File image) {
    if (mounted) {
      setState(() {
        this._image = image;
      });
    }
  }
}
