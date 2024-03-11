// import 'dart:convert';

// import 'package:connectivity_wrapper/connectivity_wrapper.dart';
// import 'package:http/http.dart' as http;
// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:ihl/constants/routes.dart';
// import 'package:ihl/constants/app_texts.dart';
// import 'package:ihl/utils/SpUtil.dart';
// import 'package:ihl/widgets/offline_widget.dart';
// import 'package:pin_code_fields/pin_code_fields.dart';
// import 'package:ihl/constants/api.dart';

// final iHLUrl1 = API.iHLUrl;
// final ihlToken1 = API.ihlToken;

// /// complete screen when pops returns true when otp verified (passmobile) 🌸
// class VerifyMob extends StatefulWidget {
//   final String mobileNumber;
//   final Function next;
//   VerifyMob({Key key, @required this.mobileNumber, this.next})
//       : super(key: key);

//   @override
//   _VerifyMobState createState() => _VerifyMobState();
// }

// class _VerifyMobState extends State<VerifyMob> with TickerProviderStateMixin {
//   TextEditingController codeController = TextEditingController();
//   StreamController<ErrorAnimationType> errorController =
//       StreamController<ErrorAnimationType>();

//   String currentText = "";
//   final _formKey = GlobalKey<FormState>();
//   bool _autoValidate = false;
//   bool hasError = false;
//   bool otpSent = false;
//   String otp;
//   Timer _timer;
//   int counter = 30;
//   var respstatus;
//   void _startTimer() {
//     counter = 30;
//     _timer = Timer.periodic(Duration(seconds: 1), (timer) {
//       if (counter > 0) {
//         if (this.mounted) {
//           setState(() {
//             counter--;
//           });
//         }
//       } else {
//         _timer.cancel();
//       }
//     });
//   }

//   @override
//   void dispose() {
//     super.dispose();
//     _timer.cancel();
//     codeController.dispose();
//   }

//   @override
//   void initState() {
//     super.initState();
//     sendOtp(context);
//   }


//   Future<String> test() {
//     return Future.delayed(
//         Duration(
//           seconds: 1,
//         ),
//         () => 'sent');
//   }

//   String message({String otp}) {
//     return 'Dear IHL User, Your One Time Password for verification is: ' + otp;
//   }

//   Future<dynamic> sendMessageApi({String otp}) async {
//     final resp = await http.get(otpServiceEndpoint(
//         message: message(otp: otp), mobile: widget.mobileNumber));
//     return resp.body;
//   }

//     Future<String> genOTP(number, email) async {
//     final response = await http.get(
//         API.iHLUrl+"/login/send_registration_otp_verify?email=" +
//             email +
//             "&mobile=" +
//             number +
//             "&from=mobile");
//     if (response.statusCode == 200) {
//       if (response.body != null || response.body != "[]") {
//         var output = json.decode(response.body);
//         respstatus = output["status"];
//         otp = output["OTP"];
//         print(otp);
//       }
//     }

//     return otp.toString();
//   }

//   Future<String> sendOtp(BuildContext context) async {
//     if (this.mounted) {
//       setState(() {
//         otpSent = false;
//       });
//     }
//     var email = SpUtil.getString('email');
//     var genotp = await genOTP(widget.mobileNumber, email);
//     // var resp = await sendMessageApi(otp: genotp); 119023
//     if (respstatus == 'sent_sucess') {
//       if (this.mounted) {
//         setState(() {
//           otpSent = true;
//           otp = genotp;
//           _startTimer();
//           currentText = '';
//           codeController.clear();
//         });
//       }
//     } else {
//       Navigator.of(context).pop(false);
//     }
//   }

//   Widget codeTextField() {
//     return PinCodeTextField(
//       backgroundColor: Color(0xffF4F6FA),
//       length: 6,
//       obscureText: false,
//       animationType: AnimationType.fade,
//       keyboardType: TextInputType.number,
//       pinTheme: PinTheme(
//         shape: PinCodeFieldShape.circle,
//         activeColor: Color(0xffDBEEFC),
//         inactiveColor: AppColors.primaryColor,
//         activeFillColor: AppColors.primaryColor,
//         fieldHeight: 50,
//         fieldWidth: 40,
//       ),
//       validator: (v) {
//         if (v.length != 6) {
//           return "OTP is not complete";
//         } else {
//           if (v != otp) {
//             return "Incorrect OTP";
//           } else {
//             return null;
//           }
//         }
//       },
//       animationDuration: Duration(milliseconds: 300),
//       errorAnimationController: errorController,
//       controller: codeController,
//       errorTextSpace: 20,
//       onCompleted: (v) {},
//       autoDisposeControllers: false,
//       onChanged: (value) {
//         if (this.mounted) {
//           setState(() {
//             currentText = value;
//           });
//         }
//       }, appContext: context,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         FocusScopeNode currentFocus = FocusScope.of(context);
//         if (!currentFocus.hasPrimaryFocus) {
//           currentFocus.unfocus();
//         }
//       },
//       child: SafeArea(
//         top: true,
//         child: ConnectivityWidgetWrapper(
//           disableInteraction: true,
//           offlineWidget: OfflineWidget(),
//           child: Scaffold(
//             appBar: AppBar(
//               backgroundColor: Colors.transparent,
//               elevation: 0.0,
//               title: Padding(
//                   padding: const EdgeInsets.only(left: 20), child: Text('')),
//               leading: IconButton(
//                 icon: Icon(Icons.arrow_back_ios),
//                 onPressed: () => Navigator.of(context).pop(),
//                 color: Colors.black,
//               ),
//             ),
//             backgroundColor: Color(0xffF4F6FA),
//             body: Form(
//               key: _formKey,
//               autovalidateMode:AutovalidateMode.onUserInteraction,
//               child: SingleChildScrollView(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: <Widget>[
//                     SizedBox(
//                       height: 2,
//                     ),
//                     Text(
//                       'Verify your number',
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                           color: Color.fromRGBO(109, 110, 113, 1),
//                           fontFamily: 'Poppins',
//                           fontSize: 26,
//                           letterSpacing: 0,
//                           fontWeight: FontWeight.bold,
//                           height: 1.33),
//                     ),
//                     SizedBox(
//                       height: 3,
//                     ),
//                     otpSent
//                         ? Column(
//                             children: [
//                               Padding(
//                                 padding: const EdgeInsets.only(
//                                     left: 50.0, right: 50.0),
//                                 child: Text(
//                                   'We have sent a text to you on ${widget.mobileNumber}',
//                                   textAlign: TextAlign.center,
//                                   style: TextStyle(
//                                       color: Color.fromRGBO(109, 110, 113, 1),
//                                       fontFamily: 'Poppins',
//                                       fontSize: 15,
//                                       letterSpacing: 0.2,
//                                       fontWeight: FontWeight.normal,
//                                       height: 1),
//                                 ),
//                               ),
//                             ],
//                           )
//                         : Container(
//                             child: Column(
//                               children: [
//                                 Padding(
//                                   padding: const EdgeInsets.only(
//                                       left: 50.0, right: 50.0),
//                                   child: Text(
//                                     'Please wait while we\'re sending OTP on ${widget.mobileNumber}',
//                                     textAlign: TextAlign.center,
//                                     style: TextStyle(
//                                         color: Color.fromRGBO(109, 110, 113, 1),
//                                         fontFamily: 'Poppins',
//                                         fontSize: 15,
//                                         letterSpacing: 0.2,
//                                         fontWeight: FontWeight.normal,
//                                         height: 1),
//                                   ),
//                                 ),
//                                 Padding(
//                                   padding: const EdgeInsets.symmetric(
//                                       horizontal: 60, vertical: 70),
//                                   child: LinearProgressIndicator(),
//                                 )
//                               ],
//                             ),
//                           ),
//                     AbsorbPointer(
//                       absorbing: !otpSent,
//                       child: Opacity(
//                         opacity: otpSent ? 1 : 0,
//                         child: Column(
//                           children: [
//                             SizedBox(
//                               height: 6,
//                             ),
//                             Padding(
//                               padding:
//                                   const EdgeInsets.symmetric(horizontal: 50).copyWith(top:30),
//                               child: codeTextField(),
//                             ),
//                             SizedBox(
//                               height: 20.0,
//                             ),
//                             TextButton(
//                               textColor: Color(0xFF19a9e5),
//                               onPressed: counter > 0
//                                   ? null
//                                   : () {
//                                       sendOtp(context);
//                                     },
//                               child: Text(
//                                   counter > 0
//                                       ? 'Please wait ${counter.toString()} seconds to request new code'
//                                       : 'Send me a new code',
//                                   style: TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     fontSize: 16,
//                                   )),
//                               shape: CircleBorder(
//                                   side: BorderSide(color: Colors.transparent)),
//                             ),
//                             SizedBox(
//                               height: 6,
//                             ),
//                             Padding(
//                               padding: const EdgeInsets.only(
//                                   left: 50.0, right: 50.0),
//                               child: Center(
//                                 child: _customButton(),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _customButton() {
//     return Container(
//       height: 60.0,
//       child: GestureDetector(
//         onTap: () {
//           _formKey.currentState.validate();
//           if (currentText.length != 4 || currentText != otp) {
//             errorController.add(
//                 ErrorAnimationType.shake); // Triggering error shake animation
//             if (this.mounted) {
//               setState(() {
//                 hasError = true;
//               });
//             }
//           } else {
//             if (this.mounted) {
//               setState(() {
//                 hasError = false;
//               });
//             }
//           }
//           if (_formKey.currentState.validate()) {
//             bool n = widget.next == null;
//             if (widget.next == null) {
//               Navigator.of(context).pushNamed(Routes.Sdob);
//             } else {
//               widget.next(context);
//             }
//           } else {
//             if (this.mounted) {
//               setState(() {
//                 _autoValidate = true;
//               });
//             }
//           }
//         },
//         child: Container(
//           decoration: BoxDecoration(
//             color: Color(0xFF19a9e5),
//             borderRadius: BorderRadius.circular(20.0),
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: <Widget>[
//               Center(
//                 child: Text(
//                   AppTexts.continuee,
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                       color: Color.fromRGBO(255, 255, 255, 1),
//                       fontFamily: 'Poppins',
//                       fontSize: 16,
//                       letterSpacing: 0.2,
//                       fontWeight: FontWeight.normal,
//                       height: 1),
//                 ),
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
