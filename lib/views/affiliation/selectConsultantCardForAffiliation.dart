// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:connectanum/connectanum.dart';
// import 'package:connectanum/json.dart';
// import 'package:ihl/constants/api.dart';
// import 'package:ihl/views/affiliation/bookAppointmentForAffiliation.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:strings/strings.dart';
// import 'package:flutter/material.dart';
// import 'package:smooth_star_rating/smooth_star_rating.dart';
// import 'package:ihl/utils/app_colors.dart';
// import 'dart:math';
// import 'package:intl/intl.dart';
//
// // ignore: must_be_immutable
// class SelectConsultantCardForAffiliation extends StatefulWidget {
//   final int index;
//   Map consultant;
//   final specality;
//   Function languageFilter;
//   bool isAvailable;
//   final bool liveCall;
//   final String companyName;
//   final bool isDirectCall;
//   bool rndtf() {
//     Random rnd = Random();
//     return rnd.nextBool();
//   }
//
//   SelectConsultantCardForAffiliation(this.index, this.companyName,
//       this.consultant, this.specality, this.liveCall,
//       {this.languageFilter, this.isDirectCall}) {
//     this.isAvailable = rndtf();
//   }
//
//   @override
//   _SelectConsultantCardForAffiliationState createState() =>
//       _SelectConsultantCardForAffiliationState();
// }
//
// class _SelectConsultantCardForAffiliationState
//     extends State<SelectConsultantCardForAffiliation> {
//   Client client;
//   String status = 'Offline';
//   String NxtAvailableTxt = '';
//   Session session1;
//   http.Client _client = http.Client(); //3gb
//   @override
//   void setState(VoidCallback fn) {
//     if (mounted) {
//       super.setState(fn);
//     }
//   }
//
//   @override
//   void initState() {
//     widget.consultant['availabilityStatus'] = 'Offline';
//     update();
//     httpStatus();
//     super.initState();
//     sendSpecality();
//     image = image =
//         Image.memory(base64Decode(widget.consultant['profile_picture']));
//     //  getConsultantImageURL();
//     getConsultantAllAppointmentForToday();
//   }
//
//   final key = new GlobalKey();
//
//   getConsultantAllAppointmentForToday() async {
//     final response = await _client.post(
//       Uri.parse(API.iHLUrl + "/consult/profile_image_fetch"),
//       body: jsonEncode(<String, dynamic>{
//         'consultantIdList': [widget.consultant['ihl_consultant_id']],
//       }),
//     );
//     if (response.statusCode == 200) {
//       var imageOutput = json.decode(response.body);
//       var consultantIDAndImage = imageOutput["ihlbase64list"];
//       for (var i = 0; i < consultantIDAndImage.length; i++) {
//         if (widget.consultant['ihl_consultant_id'] ==
//             consultantIDAndImage[i]['consultant_ihl_id']) {
//           base64Image = consultantIDAndImage[i]['base_64'].toString();
//           base64Image = base64Image.replaceAll('data:image/jpeg;base64,', '');
//           base64Image = base64Image.replaceAll('}', '');
//           base64Image = base64Image.replaceAll('data:image/jpegbase64,', '');
//           if (this.mounted) {
//             setState(() {
//               consultantImage = base64Image;
//             });
//           }
//           if (consultantImage == null || consultantImage == "") {
//             widget.consultant['profile_picture'] = AvatarImage.defaultUrl;
//             image = Image.memory(
//                 base64Decode(widget.consultant['profile_picture']));
//           } else {
//             widget.consultant['profile_picture'] = consultantImage;
//             image = Image.memory(
//                 base64Decode(widget.consultant['profile_picture']));
//           }
//         }
//       }
//     } else {
//       print(response.body);
//     }
//   }
//
//   @override
//   void dispose() {
//     // ignore: unrelated_type_equality_checks
//     if (session1 != null) {
//       session1.close();
//     }
//     super.dispose();
//   }
//
//   var base64Image;
//   var consultantImage;
//   var image;
//
//   Future getConsultantImageURL() async {
//     final response = await _client.post(
//       Uri.parse(API.iHLUrl + "/consult/profile_image_fetch"),
//       body: jsonEncode(<String, dynamic>{
//         'consultantIdList': [widget.consultant['ihl_consultant_id']],
//       }),
//     );
//     if (response.statusCode == 200) {
//       var imageOutput = json.decode(response.body);
//       var consultantIDAndImage = imageOutput["ihlbase64list"];
//       for (var i = 0; i < consultantIDAndImage.length; i++) {
//         if (widget.consultant['ihl_consultant_id'] ==
//             consultantIDAndImage[i]['consultant_ihl_id']) {
//           base64Image = consultantIDAndImage[i]['base_64'].toString();
//           base64Image = base64Image.replaceAll('data:image/jpeg;base64,', '');
//           base64Image = base64Image.replaceAll('}', '');
//           base64Image = base64Image.replaceAll('data:image/jpegbase64,', '');
//           if (this.mounted) {
//             setState(() {
//               consultantImage = base64Image;
//             });
//           }
//           if (consultantImage == null || consultantImage == "") {
//             widget.consultant['profile_picture'] = AvatarImage.defaultUrl;
//             image = Image.memory(
//                 base64Decode(widget.consultant['profile_picture']));
//           } else {
//             widget.consultant['profile_picture'] = consultantImage;
//             image = Image.memory(
//                 base64Decode(widget.consultant['profile_picture']));
//           }
//         }
//       }
//     } else {
//       print(response.body);
//     }
//   }
//
//   sendSpecality() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     prefs.setString("selectedSpecality", widget.specality);
//   }
//
//   void connect() {
//     client = Client(
//         realm: 'crossbardemo',
//         transport: WebSocketTransport(
//           API.crossbarUrl,
//           Serializer(),
//           WebSocketSerialization.SERIALIZATION_JSON,
//         ));
//   }
//
//   getAvailableTime(status) async {
//     if (status != 'offline' && status != 'busy') status = 'offline';
//     try {
//       final response = await _client.get(
//         Uri.parse(API.iHLUrl +
//             '/consult/busy_availability_check?ihl_consultant_id=${widget.consultant['ihl_consultant_id']}&vendor_id=${widget.consultant['vendor_id']}&status=${status.toString().toLowerCase()}'),
//         // '/consult/busy_availability_check?ihl_consultant_id=5764b9c8cf1a48b885b1cc4c4f93aefb&vendor_id=GENIX&status=offline'),
//         // body: jsonEncode(<String, dynamic>{
//         //   "consultant_id": [widget.consultant['ihl_consultant_id']]
//         // })
//       );
//       if (response.statusCode == 200 && response.body != '') {
//         var res = jsonDecode(response.body);
//         var dt = '';
//         if (res['responce'].toString().contains('n'))
//           return res['responce'];
//         else
//           dt = res['responce'].toString();
//         // dt = res['responce'].toString().replaceAll('/', '-');
//         // var availableSlotDateTime = dt.toString().substring(0, 10);
//         // var oasdt = dt.toString().substring(
//         //       10,
//         //     );
//         // var dt = "5/21/2022 1:00:00 PM";
//         var splDt = dt.split(' ');
//         var splDt2 = splDt[1].toString().split(':');
//         var availableSlotDateTime =
//             splDt2[0].toString() + ':' + splDt2[1].toString() + ' ' + splDt[2];
//         //     courseEndDuration + courseEndTime; //20-04-2022 07:00 PM
//         // DateTime availableSlotDateTime =dt;
//         // DateFormat("dd-MM-yyyy hh:mm a").parse(dt);
//         print(availableSlotDateTime);
//         return availableSlotDateTime.toString();
//       } else {
//         return 'no Slots Found';
//       }
//     } catch (e) {
//       print(e.toString());
//       return 'no Slots Found';
//     }
//   }
//
//   void httpStatus() async {
//     final response = await _client.post(
//       Uri.parse(API.iHLUrl + '/consult/getConsultantLiveStatus'),
//       body: jsonEncode(<String, dynamic>{
//         "consultant_id": [widget.consultant['ihl_consultant_id']]
//       }),
//     );
//     if (response.statusCode == 200) {
//       if (response.body != '"[]"') {
//         var parsedString = response.body.replaceAll('&quot', '"');
//         var parsedString1 = parsedString.replaceAll(";", "");
//         var parsedString2 = parsedString1.replaceAll('"[', '[');
//         var parsedString3 = parsedString2.replaceAll(']"', ']');
//         var finalOutput = json.decode(parsedString3);
//         var doctorId = widget.consultant['ihl_consultant_id'];
//         if (doctorId == finalOutput[0]['consultant_id']) {
//           NxtAvailableTxt = await getAvailableTime(
//               finalOutput[0]['status'].toString().toLowerCase());
//           if (this.mounted) {
//             setState(() {
//               status = camelize(finalOutput[0]['status'].toString());
//               if (status == null ||
//                   status == "" ||
//                   status == "null" ||
//                   status == "Null") {
//                 status = "Offline";
//               }
//               widget.consultant['availabilityStatus'] = status;
//             });
//           }
//         }
//       } else {}
//     }
//   }
//
//   void update() async {
//     if (session1 != null) {
//       session1.close();
//     }
//     connect();
//     var doctorId = widget.consultant['ihl_consultant_id'];
//     session1 = await client.connect().first;
//     try {
//       final subscription = await session1.subscribe(
//           'ihl_update_doctor_status_channel',
//           options: SubscribeOptions(get_retained: true));
//       subscription.eventStream.listen((event) {
//         Map data = event.arguments[0];
//         var docStatus = data['data']['status'];
//         if (data['sender_id'] == doctorId) {
//           if (this.mounted) {
//             setState(() {
//               status = docStatus;
//               widget.consultant['availabilityStatus'] = docStatus;
//             });
//           }
//         }
//       });
//     } on Abort catch (abort) {
//       print(abort.message.message);
//     }
//   }
//
//   Widget banner() {
//     Color color = AppColors.primaryAccentColor;
//     if (status == 'Online' || status == 'online') {
//       color = Colors.green;
//     }
//     if (status == 'Busy' || status == 'busy') {
//       color = Colors.red;
//     }
//     if (status == 'Offline' || status == 'offline') {
//       color = Colors.grey;
//     }
//     return Positioned(
//       top: -25,
//       left: -60,
//       child: Transform.rotate(
//         angle: -pi / 4,
//         child: Container(
//           color: color,
//           child: SizedBox(
//             width: 150,
//             child: Column(
//               children: [
//                 SizedBox(
//                   height: 50,
//                 ),
//                 Center(
//                   child: Text(
//                     camelize(status.toString()),
//                     style: TextStyle(color: Colors.white),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget badge() {
//     if (widget.isAvailable == true) {
//       return Positioned(
//         right: 0,
//         bottom: -5,
//         child: FilterChip(
//           label: Icon(Icons.check),
//           backgroundColor: Colors.green,
//           onSelected: (value) {},
//           padding: EdgeInsets.all(0),
//         ),
//       );
//     }
//     return Positioned(
//       right: 0,
//       bottom: -5,
//       child: FilterChip(
//         label: Icon(Icons.close),
//         backgroundColor: Colors.red,
//         onSelected: (value) {},
//       ),
//     );
//   }
//
//   List<Widget> specialities() {
//     List sp = widget.consultant['consultant_speciality'];
//     return sp
//             ?.map(
//               (e) => FilterChip(
//                 label: Text(
//                   camelize(e.toString()),
//                   style: TextStyle(
//                     color: AppColors.primaryAccentColor,
//                   ),
//                 ),
//                 padding: EdgeInsets.all(0),
//                 backgroundColor: AppColors.appItemShadowColor,
//                 onSelected: (bool value) {},
//               ),
//             )
//             ?.toList() ??
//         [];
//   }
//
//   List<Widget> languages() {
//     List lang = widget.consultant['languages_Spoken'];
//     List showLang = [];
//     String otherLangsTxt = '';
//
//     if (lang.isNotEmpty) {
//       if (lang.length > 2) {
//         // showLang = ['${lang[0]}, ${lang[1]},...', '007'];
//         showLang = ['${lang[0]}', '${lang[1]}...,', '007'];
//         // otherLangsTxt =
//         lang.forEach((element) {
//           if (lang.indexOf(element) != 0 && lang.indexOf(element) != 1)
//             otherLangsTxt =
//                 otherLangsTxt == '' ? element : otherLangsTxt + ',' + element;
//         });
//       } else if (lang.length == 2) {
//         showLang = ['${lang[0]}', '${lang[1]}'];
//       } else if (lang.length == 1) {
//         showLang = [lang[0]];
//       } else {
//         showLang = [lang[0]];
//       }
//     } else {
//       showLang = [];
//     }
//     var length = lang.isNotEmpty ? lang.length - showLang.length + 1 : 0;
//     return showLang
//             .map(
//               (e) => Visibility(
//                 visible: lang.contains("") ? false : true,
//                 child: e != '007'
//                     ? lang.indexOf(e) == 0
//                         ? showLang.length > 1
//                             ? Visibility(
//                                 visible: lang.indexOf(e) == 0,
//                                 child: Icon(
//                                   Icons.chat_bubble,
//                                   color: AppColors.primaryAccentColor,
//                                   size: 17,
//                                 ),
//                               )
//                             : Row(
//                                 children: [
//                                   Visibility(
//                                     visible: lang.indexOf(e) == 0,
//                                     child: Icon(
//                                       Icons.chat_bubble,
//                                       color: AppColors.primaryAccentColor,
//                                       size: 17,
//                                     ),
//                                   ),
//                                   Text(
//                                     camelize(e.toString()),
//                                     style: TextStyle(
//                                       color: AppColors.primaryColor,
//                                     ),
//                                   )
//                                 ],
//                               )
//                         : Text(
//                             camelize(lang[0].toString()) +
//                                 ',' +
//                                 camelize(e.toString()),
//                             style: TextStyle(
//                               color: AppColors.primaryColor,
//                             ),
//                           )
//                     // : Text(
//                     //     camelize(e.toString()),
//                     //     style: TextStyle(
//                     //       color: AppColors.primaryColor,
//                     //     ),
//                     //   )
//                     : Tooltip(
//                         key: key,
//                         child: GestureDetector(
//                           onTap: () {
//                             final dynamic tooltip = key.currentState;
//                             tooltip.ensureTooltipVisible();
//                           },
//                           child: Container(
//                               decoration: BoxDecoration(
//                                 color: AppColors.primaryAccentColor,
//                                 borderRadius: BorderRadius.circular(4),
//                               ),
//                               padding: EdgeInsets.all(0.5),
//                               child: Text(
//                                 '+$length',
//                                 style: TextStyle(color: FitnessAppTheme.white),
//                               )),
//                         ),
//                         message: '$otherLangsTxt',
//                       ),
//               ),
//             )
//             ?.toList() ??
//         [];
//     return lang
//             .map(
//               (e) => Visibility(
//                 visible: lang.contains("") ? false : true,
//                 child: FilterChip(
//                   label: Text(
//                     camelize(e.toString()),
//                     style: TextStyle(
//                       color: AppColors.primaryColor,
//                     ),
//                   ),
//                   padding: EdgeInsets.all(0),
//                   onSelected: (bool value) {
//                     widget.languageFilter(e.toString());
//                   },
//                 ),
//               ),
//             )
//             ?.toList() ??
//         [];
//   }
//
//   // List<Widget> languages() {
//   //   List lang = widget.consultant['languages_Spoken'];
//   //   return lang
//   //           .map(
//   //             (e) => Visibility(
//   //               visible: lang.contains("") ? false : true,
//   //               child: FilterChip(
//   //                 label: Text(
//   //                   camelize(e.toString()),
//   //                   style: TextStyle(
//   //                     color: AppColors.primaryColor,
//   //                   ),
//   //                 ),
//   //                 padding: EdgeInsets.all(0),
//   //                 onSelected: (bool value) {
//   //                   widget.languageFilter(e.toString());
//   //                 },
//   //               ),
//   //             ),
//   //           )
//   //           ?.toList() ??
//   //       [];
//   // }
//
//   @override
//   Widget build(BuildContext context) {
//     // var consultantImage = widget.consultant['profile_picture'] == null
//     //     ? null
//     //     : Image.memory(base64Decode(
//     //     widget.consultant['profile_picture']));
//     return widget.isDirectCall
//         ? Offstage(
//             // offstage: status != 'Online' &&
//             //     status != 'online' &&
//             //     status != 'M' &&
//             //     status != 'F',
//             ///because now we are showing every consultant in live call also
//             ///if not then uncomment this above 4 line
//             offstage: false,
//             child: Card(
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(15),
//               ),
//               elevation: 4,
//               color: AppColors.cardColor,
//               child: InkWell(
//                 key: Key('affiliatedConsultant${widget.index}'),
//                 onTap: () {
//                   Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                           builder: (context) => BookAppointmentForAffiliation(
//                                 doctor: widget.consultant,
//                                 companyName: widget.companyName,
//                               )));
//                 },
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(15),
//                   child: Stack(
//                     children: [
//                       Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Center(
//                               child: Row(
//                                 children: [
//                                   Column(
//                                     children: [
//                                       Padding(
//                                         padding: const EdgeInsets.only(
//                                             top: 25,
//                                             left: 25,
//                                             right: 25,
//                                             bottom: 5),
//                                         child: CircleAvatar(
//                                           radius: 50.0,
//                                           backgroundImage: image == null
//                                               ? null
//                                               : image.image,
//                                           backgroundColor:
//                                               AppColors.primaryAccentColor,
//                                         ),
//                                       ),
//                                       Visibility(
//                                         // visible: false,
//                                         visible: (status.toLowerCase() ==
//                                                 'offline') &&
//                                             NxtAvailableTxt != '' &&
//                                             !NxtAvailableTxt.contains('n'),
//                                         child: FilterChip(
//                                           label: Text(
//                                             ' Yet To Arrive ',
//                                             // camelize('Available at 06:00 PM'),
//                                             style: TextStyle(
//                                               color: AppColors
//                                                   .primaryAccentColor
//                                                   .withOpacity(0.9),
//                                             ),
//                                           ),
//                                           padding: EdgeInsets.all(0),
//                                           backgroundColor:
//                                               Colors.amber.withOpacity(0.3),
//                                           onSelected: (bool value) {},
//                                         ),
//                                       ),
//                                       Visibility(
//                                         // visible: false,
//                                         visible:
//                                             (status.toLowerCase() == 'busy' ||
//                                                     status.toLowerCase() ==
//                                                         'offline') &&
//                                                 NxtAvailableTxt != '',
//                                         child: FilterChip(
//                                           label: Text(
//                                             NxtAvailableTxt.contains('n')
//                                                 ? camelize(NxtAvailableTxt)
//                                                 : 'Available at ' +
//                                                     NxtAvailableTxt,
//                                             // camelize('Available at 06:00 PM'),
//                                             style: TextStyle(
//                                               color: AppColors
//                                                   .primaryAccentColor
//                                                   .withOpacity(0.9),
//                                             ),
//                                           ),
//                                           padding: EdgeInsets.all(0),
//                                           backgroundColor: Colors
//                                               .lightGreenAccent
//                                               .withOpacity(0.3),
//                                           onSelected: (bool value) {},
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   Expanded(
//                                     child: Padding(
//                                       padding: const EdgeInsets.all(8.0),
//                                       child: Column(
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                         children: [
//                                           Text(
//                                             camelize(widget.consultant['name']
//                                                 .toString()),
//                                             style: TextStyle(
//                                               letterSpacing: 2.0,
//                                               color:
//                                                   AppColors.primaryAccentColor,
//                                             ),
//                                           ),
//                                           Text(
//                                             "Experience: " +
//                                                 widget.consultant['experience']
//                                                     .toString(),
//                                             style: TextStyle(
//                                               color: AppColors.lightTextColor,
//                                             ),
//                                           ),
//                                           SmoothStarRating(
//                                             allowHalfRating: false,
//                                             onRated: (v) {},
//                                             starCount: 5,
//                                             rating:
//                                                 widget.consultant['ratings'],
//                                             size: 20.0,
//                                             isReadOnly: true,
//                                             color: Colors.amberAccent,
//                                             borderColor: Colors.grey,
//                                             spacing: 0.0,
//                                           ),
//                                           Wrap(
//                                             direction: Axis.horizontal,
//                                             children: specialities(),
//                                             runSpacing: 0,
//                                             spacing: 8,
//                                           ),
//                                           Visibility(
//                                             visible: widget.consultant[
//                                                         "languages_Spoken"] ==
//                                                     null
//                                                 ? false
//                                                 : true,
//                                             child: Wrap(
//                                               children: languages(),
//                                               runSpacing: 0,
//                                               spacing: 8,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             SizedBox(
//                               height: 2.0,
//                             ),
//                           ]),
//                       banner()
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           )
//         : Card(
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(15),
//             ),
//             elevation: 4,
//             color: AppColors.cardColor,
//             child: InkWell(
//               key: Key('affiliatedConsultant${widget.index}'),
//               onTap: () {
//                 Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                         builder: (context) => BookAppointmentForAffiliation(
//                               doctor: widget.consultant,
//                               companyName: widget.companyName,
//                             )));
//               },
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(15),
//                 child: Stack(
//                   children: [
//                     Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Center(
//                             child: Row(
//                               children: [
//                                 Column(
//                                   children: [
//                                     Padding(
//                                       padding: const EdgeInsets.only(
//                                           top: 25,
//                                           left: 25,
//                                           right: 25,
//                                           bottom: 5),
//                                       child: CircleAvatar(
//                                         radius: 50.0,
//                                         backgroundImage:
//                                             image == null ? null : image.image,
//                                         backgroundColor:
//                                             AppColors.primaryAccentColor,
//                                       ),
//                                     ),
//                                     Visibility(
//                                       // visible: false,
//                                       visible:
//                                           (status.toLowerCase() == 'offline') &&
//                                               NxtAvailableTxt != '' &&
//                                               !NxtAvailableTxt.contains('n'),
//                                       child: FilterChip(
//                                         label: Text(
//                                           ' Yet To Arrive ',
//                                           // camelize('Available at 06:00 PM'),
//                                           style: TextStyle(
//                                             color: AppColors.primaryAccentColor
//                                                 .withOpacity(0.9),
//                                           ),
//                                         ),
//                                         padding: EdgeInsets.all(0),
//                                         backgroundColor:
//                                             Colors.amber.withOpacity(0.3),
//                                         onSelected: (bool value) {},
//                                       ),
//                                     ),
//                                     Visibility(
//                                       // visible: false,
//                                       visible:
//                                           (status.toLowerCase() == 'busy' ||
//                                                   status.toLowerCase() ==
//                                                       'offline') &&
//                                               NxtAvailableTxt != '',
//                                       child: FilterChip(
//                                         label: Text(
//                                           NxtAvailableTxt.contains('n')
//                                               ? camelize(NxtAvailableTxt)
//                                               : 'Available at ' +
//                                                   NxtAvailableTxt,
//                                           // camelize('Available at 06:00 PM'),
//                                           style: TextStyle(
//                                             color: AppColors.primaryAccentColor
//                                                 .withOpacity(0.9),
//                                           ),
//                                         ),
//                                         padding: EdgeInsets.all(0),
//                                         backgroundColor: Colors.lightGreenAccent
//                                             .withOpacity(0.3),
//                                         onSelected: (bool value) {},
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 Expanded(
//                                   child: Padding(
//                                     padding: const EdgeInsets.all(8.0),
//                                     child: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         Text(
//                                           camelize(widget.consultant['name']
//                                               .toString()),
//                                           style: TextStyle(
//                                             letterSpacing: 2.0,
//                                             color: AppColors.primaryAccentColor,
//                                           ),
//                                         ),
//                                         Text(
//                                           "Experience: " +
//                                               widget.consultant['experience']
//                                                   .toString(),
//                                           style: TextStyle(
//                                             color: AppColors.lightTextColor,
//                                           ),
//                                         ),
//                                         SmoothStarRating(
//                                           allowHalfRating: false,
//                                           onRated: (v) {},
//                                           starCount: 5,
//                                           rating: widget.consultant['ratings'],
//                                           size: 20.0,
//                                           isReadOnly: true,
//                                           color: Colors.amberAccent,
//                                           borderColor: Colors.grey,
//                                           spacing: 0.0,
//                                         ),
//                                         Wrap(
//                                           direction: Axis.horizontal,
//                                           children: specialities(),
//                                           runSpacing: 0,
//                                           spacing: 8,
//                                         ),
//                                         Visibility(
//                                           visible: widget.consultant[
//                                                       "languages_Spoken"] ==
//                                                   null
//                                               ? false
//                                               : true,
//                                           child: Wrap(
//                                             children: languages(),
//                                             runSpacing: 0,
//                                             spacing: 8,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           SizedBox(
//                             height: 2.0,
//                           ),
//                         ]),
//                     banner()
//                   ],
//                 ),
//               ),
//             ),
//           );
//   }
// }

import 'dart:convert';
import 'dart:math';

import 'package:connectanum/connectanum.dart';
import 'package:connectanum/json.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:ihl/constants/api.dart';
import 'package:ihl/repositories/api_repository.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/views/affiliation/bookAppointmentForAffiliation.dart';
import 'package:ihl/widgets/teleconsulation/commom_yet_to_arrive.dart';
import 'package:ihl/widgets/teleconsulation/serviceWidgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'package:strings/strings.dart';

import '../../constants/routes.dart';
import '../../widgets/toc.dart';

// import '';
// ignore: must_be_immutable
class SelectConsultantCardForAffiliation extends StatefulWidget {
  final int index;
  Map consultant;
  final specality;
  Function languageFilter;
  bool isAvailable;
  final bool liveCall;
  final String companyName;
  final bool isDirectCall;

  bool rndtf() {
    Random rnd = Random();
    return rnd.nextBool();
  }

  SelectConsultantCardForAffiliation(
      this.index, this.companyName, this.consultant, this.specality, this.liveCall,
      {this.languageFilter, this.isDirectCall}) {
    this.isAvailable = rndtf();
  }

  @override
  _SelectConsultantCardForAffiliationState createState() =>
      _SelectConsultantCardForAffiliationState();
}

class _SelectConsultantCardForAffiliationState extends State<SelectConsultantCardForAffiliation> {
  Client client;
  String status = 'Offline';
  String NxtAvailableTxt = '', currentAvailable = '';
  Session session1;
  http.Client _client = http.Client(); //3gb
  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    widget.consultant['availabilityStatus'] = 'Offline';
    update();
    httpStatus();
    super.initState();
    sendSpecality();
    if (widget.consultant['profile_picture'].toString() != 'null') {
      image = image = Image.memory(base64Decode(widget.consultant['profile_picture']));
    } else {
      image = Image.memory(base64Decode(AvatarImage.defaultUrl));
    }

    //  getConsultantImageURL();
    getConsultantAllAppointmentForToday(widget.consultant['vendor_id'] == "GENIX"
        ? [widget.consultant['vendor_consultant_id'], widget.consultant['vendor_id']]
        : [widget.consultant['ihl_consultant_id'], widget.consultant['vendor_id']]);
  }

  final key = new GlobalKey();
  final speciality_key = new GlobalKey();

  getConsultantAllAppointmentForToday(map) async {
    try {
      var bodyGenix = jsonEncode(<String, dynamic>{
        'vendorIdList': [map[0]],
        "consultantIdList": [""],
      });
      var bodyIhl = jsonEncode(<String, dynamic>{
        'consultantIdList': [map[0]],
        "vendorIdList": [""],
      });
      final response = await _client.post(Uri.parse(API.iHLUrl + "/consult/profile_image_fetch"),
          body: map[1] == 'GENIX' ? bodyGenix : bodyIhl);
      if (response.statusCode == 200) {
        var imageOutput = json.decode(response.body);
        // var consultantIDAndImage = imageOutput["ihlbase64list"];
        var consultantIDAndImage =
            map[1] == 'GENIX' ? imageOutput["genixbase64list"] : imageOutput["ihlbase64list"];
        for (var i = 0; i < consultantIDAndImage.length; i++) {
          var chk_id = map[1] == 'GENIX'
              ? widget.consultant['vendor_consultant_id']
              : widget.consultant['ihl_consultant_id'];
          if (chk_id == consultantIDAndImage[i]['consultant_ihl_id']) {
            base64Image = consultantIDAndImage[i]['base_64'].toString();
            base64Image = base64Image.replaceAll('data:image/jpeg;base64,', '');
            base64Image = base64Image.replaceAll('}', '');
            base64Image = base64Image.replaceAll('data:image/jpegbase64,', '');
            if (this.mounted) {
              setState(() {
                consultantImage = base64Image;
              });
            }
            if (consultantImage == null || consultantImage == "") {
              widget.consultant['profile_picture'] = AvatarImage.defaultUrl;
              image = Image.memory(base64Decode(widget.consultant['profile_picture']));
            } else {
              widget.consultant['profile_picture'] = consultantImage;
              image = Image.memory(base64Decode(widget.consultant['profile_picture']));
            }
          }
        }
      } else {
        print(response.body);
      }
    } catch (e) {
      print(e.toString());
      widget.consultant['profile_picture'] = AvatarImage.defaultUrl;
      image = Image.memory(base64Decode(widget.consultant['profile_picture']));
    }
  }

  @override
  void dispose() {
    // ignore: unrelated_type_equality_checks
    if (session1 != null) {
      session1.close();
    }
    super.dispose();
  }

  var base64Image;
  var consultantImage;
  var image;

  Future getConsultantImageURL() async {
    final response = await _client.post(
      Uri.parse(API.iHLUrl + "/consult/profile_image_fetch"),
      body: jsonEncode(<String, dynamic>{
        'consultantIdList': [widget.consultant['ihl_consultant_id']],
      }),
    );
    if (response.statusCode == 200) {
      var imageOutput = json.decode(response.body);
      var consultantIDAndImage = imageOutput["ihlbase64list"];
      for (var i = 0; i < consultantIDAndImage.length; i++) {
        if (widget.consultant['ihl_consultant_id'] ==
            consultantIDAndImage[i]['consultant_ihl_id']) {
          base64Image = consultantIDAndImage[i]['base_64'].toString();
          base64Image = base64Image.replaceAll('data:image/jpeg;base64,', '');
          base64Image = base64Image.replaceAll('}', '');
          base64Image = base64Image.replaceAll('data:image/jpegbase64,', '');
          if (this.mounted) {
            setState(() {
              consultantImage = base64Image;
            });
          }
          if (consultantImage == null || consultantImage == "") {
            widget.consultant['profile_picture'] = AvatarImage.defaultUrl;
            image = Image.memory(base64Decode(widget.consultant['profile_picture']));
          } else {
            widget.consultant['profile_picture'] = consultantImage;
            image = Image.memory(base64Decode(widget.consultant['profile_picture']));
          }
        }
      }
    } else {
      print(response.body);
    }
  }

  sendSpecality() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("selectedSpecality", widget.specality);
  }

  void connect() {
    client = Client(
        realm: 'crossbardemo',
        transport: WebSocketTransport(
          API.crossbarUrl,
          Serializer(),
          WebSocketSerialization.SERIALIZATION_JSON,
        ));
  }

  getAvailableTime(status) async {
    if (status != 'offline' && status != 'busy') status = 'offline';
    try {
      var availableSlot = await Apirepository().yetToArrive(
          consultId: widget.consultant['ihl_consultant_id'],
          venderName: widget.consultant['vendor_id'],
          status: status);
      if (availableSlot[0] != 'NA') {
        currentAvailable = availableSlot[0];
      }
      return availableSlot[1];
    } catch (e) {
      print(e.toString());
      return 'no Slots Found';
    }
  }

  void httpStatus() async {
    final response = await _client.post(
      Uri.parse(API.iHLUrl + '/consult/getConsultantLiveStatus'),
      body: jsonEncode(<String, dynamic>{
        "consultant_id": [widget.consultant['ihl_consultant_id']]
      }),
    );
    if (response.statusCode == 200) {
      if (response.body != '"[]"') {
        var parsedString = response.body.replaceAll('&quot', '"');
        var parsedString1 = parsedString.replaceAll(";", "");
        var parsedString2 = parsedString1.replaceAll('"[', '[');
        var parsedString3 = parsedString2.replaceAll(']"', ']');
        var finalOutput = json.decode(parsedString3);
        var doctorId = widget.consultant['ihl_consultant_id'];
        if (doctorId == finalOutput[0]['consultant_id']) {
          NxtAvailableTxt =
              await getAvailableTime(finalOutput[0]['status'].toString().toLowerCase());
          if (this.mounted) {
            setState(() {
              status = camelize(finalOutput[0]['status'].toString());
              if (status == null || status == "" || status == "null" || status == "Null") {
                status = "Offline";
              }
              widget.consultant['availabilityStatus'] = status;
            });
          }
        }
      } else {}
    }
  }

  void update() async {
    if (session1 != null) {
      session1.close();
    }
    connect();
    var doctorId = widget.consultant['ihl_consultant_id'];
    session1 = await client.connect().first;
    try {
      final subscription = await session1.subscribe('ihl_update_doctor_status_channel',
          options: SubscribeOptions(get_retained: true));
      //unslash to work firestore online offline status 🥚🥚🥚
      // FireStoreCollections.consultantOnlineStatus.doc(doctorId).snapshots().listen((event) {
      //   if (event.exists) {
      //     var _data = event.data();
      //     if (mounted)
      //       setState(() {
      //         status = _data['status'];
      //         widget.consultant['availabilityStatus'] = status;
      //       });
      //   } else {
      //     FireStoreCollections.consultantOnlineStatus
      //         .doc(doctorId)
      //         .set({'consultantId': doctorId, 'status': status});
      // subscription.eventStream.listen((event) {
      //   Map data = event.arguments[0];
      //   var docStatus = data['data']['status'];
      //   if (data['sender_id'] == doctorId) {
      //     if (this.mounted) {
      //       setState(() {
      //         status = docStatus;
      //         widget.consultant['availabilityStatus'] = docStatus;
      //       });
      //     }
      //   }
      // });
      // }
      // }).onError((error) {
      //   if (mounted)
      //     setState(() {
      //       status = 'Offline';
      //       widget.consultant['availabilityStatus'] = status;
      //     });
      // });
      subscription.eventStream.listen((event) {
        Map data = event.arguments[0];
        var docStatus = data['data']['status'];
        if (data['sender_id'] == doctorId) {
          if (this.mounted) {
            setState(() {
              status = docStatus;
              widget.consultant['availabilityStatus'] = docStatus;
            });
          }
        }
      });
    } on Abort catch (abort) {
      print(abort.message.message);
    }
  }

  Widget banner() {
    Color color = AppColors.primaryAccentColor;
    if (status == 'Online' || status == 'online') {
      color = Colors.green;
    }
    if (status == 'Busy' || status == 'busy') {
      color = Colors.red;
    }
    if (status == 'Offline' || status == 'offline') {
      color = Colors.grey;
    }
    return Positioned(
      top: -25,
      left: -60,
      child: Transform.rotate(
        angle: -pi / 4,
        child: Container(
          color: color,
          child: SizedBox(
            width: 150,
            child: Column(
              children: [
                SizedBox(
                  height: 50,
                ),
                Center(
                  child: Text(
                    camelize(status.toString()),
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget badge() {
    if (widget.isAvailable == true) {
      return Positioned(
        right: 0,
        bottom: -5,
        child: FilterChip(
          label: Icon(Icons.check),
          backgroundColor: Colors.green,
          onSelected: (value) {},
          padding: EdgeInsets.all(0),
        ),
      );
    }
    return Positioned(
      right: 0,
      bottom: -5,
      child: FilterChip(
        label: Icon(Icons.close),
        backgroundColor: Colors.red,
        onSelected: (value) {},
      ),
    );
  }

  List<Widget> specialities() {
    List sp = widget.consultant['consultant_speciality'];
    return sp
            ?.map(
              (e) => FilterChip(
                label: Text(
                  camelize(e.toString()),
                  style: TextStyle(
                    color: AppColors.primaryAccentColor,
                  ),
                ),
                padding: EdgeInsets.all(0),
                backgroundColor: AppColors.appItemShadowColor,
                onSelected: (bool value) {},
              ),
            )
            ?.toList() ??
        [];
  }

  List<Widget> _finetuned_specialities() {
    List spec = widget.consultant['consultant_speciality'];
    var set = spec.toSet();
    spec = set.toList();
    List showSpec = [];
    String otherSpecsTxt = '';

    if (spec.isNotEmpty) {
      if (spec.length > 1) {
        // showLang = ['${lang[0]}, ${lang[1]},...', '007'];
        showSpec = ['${spec[0]},', '007'];
        // otherLangsTxt =
        spec.forEach((element) {
          if (spec.indexOf(element) != 0)
            otherSpecsTxt = otherSpecsTxt == '' ? element : otherSpecsTxt + ',' + element;
        });
      } else if (spec.length == 2) {
        showSpec = ['${spec[0]}'];
      } else if (spec.length == 1) {
        showSpec = [spec[0]];
      } else {
        showSpec = [spec[0]];
      }
    } else {
      showSpec = [];
    }
    var length = spec.isNotEmpty ? spec.length - showSpec.length + 1 : 0;
    return showSpec
            .map(
              (e) => Visibility(
                visible: spec.contains("") ? false : true,
                child: e != '007'
                    ? Text(
                        camelize(e.toString()),
                        style: TextStyle(
                          color: AppColors.lightTextColor,
                        ),
                      )

                    // : Text(
                    //     camelize(e.toString()),
                    //     style: TextStyle(
                    //       color: AppColors.primaryColor,
                    //     ),
                    //   )
                    : Tooltip(
                        key: speciality_key,
                        child: GestureDetector(
                          onTap: () {
                            final dynamic tooltip = speciality_key.currentState;
                            tooltip.ensureTooltipVisible();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.primaryAccentColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            padding: EdgeInsets.all(0.5),
                            child: Text(
                              '+$length',
                              style: TextStyle(color: FitnessAppTheme.white, fontSize: 12),
                            ),
                          ),
                        ),
                        message: '$otherSpecsTxt',
                      ),
              ),
            )
            ?.toList() ??
        [];
    // return sp
    //         ?.map(
    //           (e) => Text(
    //             camelize(e.toString()),
    //             style: TextStyle(
    //               color: AppColors.lightTextColor,
    //             ),
    //           ),
    //         )
    //         ?.toList() ??
    //     [];
  }

  List<Widget> languages() {
    List lang = widget.consultant['languages_Spoken'];
    List showLang = [];
    String otherLangsTxt = '';

    if (lang.isNotEmpty) {
      if (lang.length > 2) {
        // showLang = ['${lang[0]}, ${lang[1]},...', '007'];
        showLang = ['${lang[0]}', '${lang[1]},', '007'];
        // otherLangsTxt =
        lang.forEach((element) {
          if (lang.indexOf(element) != 0 && lang.indexOf(element) != 1)
            otherLangsTxt = otherLangsTxt == '' ? element : otherLangsTxt + ',' + element;
        });
      } else if (lang.length == 2) {
        showLang = ['${lang[0]}', '${lang[1]}'];
      } else if (lang.length == 1) {
        showLang = [lang[0]];
      } else {
        showLang = [lang[0]];
      }
    } else {
      showLang = [];
    }
    var length = lang.isNotEmpty ? lang.length - showLang.length + 1 : 0;
    return showLang
            .map(
              (e) => Visibility(
                visible: lang.contains("") ? false : true,
                child: e != '007'
                    ? lang.indexOf(e) == 0
                        ? showLang.length > 1
                            ? Visibility(
                                visible: lang.indexOf(e) == 0,
                                child: Icon(
                                  Icons.chat_bubble,
                                  color: AppColors.primaryAccentColor,
                                  size: 17,
                                ),
                              )
                            : Row(
                                children: [
                                  Visibility(
                                    visible: lang.indexOf(e) == 0,
                                    child: Icon(
                                      Icons.chat_bubble,
                                      color: AppColors.primaryAccentColor,
                                      size: 17,
                                    ),
                                  ),
                                  Text(
                                    camelize(e.toString()),
                                    style: TextStyle(
                                      color: AppColors.primaryColor,
                                    ),
                                  )
                                ],
                              )
                        : Text(
                            camelize(lang.toString().replaceAll('[', '').replaceAll(']', '')),
                            style: TextStyle(
                              color: AppColors.primaryColor,
                            ),
                            maxLines: 2,
                          )
                    // : Text(
                    //     camelize(e.toString()),
                    //     style: TextStyle(
                    //       color: AppColors.primaryColor,
                    //     ),
                    //   )
                    : Tooltip(
                        key: key,
                        child: GestureDetector(
                            onTap: () {
                              final dynamic tooltip = key.currentState;
                              tooltip.ensureTooltipVisible();
                            },
                            child: SizedBox()
                            // Container(
                            //     decoration: BoxDecoration(
                            //       color: AppColors.primaryAccentColor,
                            //       borderRadius: BorderRadius.circular(4),
                            //     ),
                            //     padding: EdgeInsets.all(0.5),
                            //     child: Text(
                            //       '+$length',
                            //       style: TextStyle(color: FitnessAppTheme.white, fontSize: 11),
                            //     )),
                            ),
                        message: '$otherLangsTxt',
                      ),
              ),
            )
            ?.toList() ??
        [];
    return lang
            .map(
              (e) => Visibility(
                visible: lang.contains("") ? false : true,
                child: FilterChip(
                  label: Text(
                    camelize(e.toString()),
                    style: TextStyle(
                      color: AppColors.primaryColor,
                    ),
                  ),
                  padding: EdgeInsets.all(0),
                  onSelected: (bool value) {
                    widget.languageFilter(e.toString());
                  },
                ),
              ),
            )
            ?.toList() ??
        [];
  }

  // List<Widget> languages() {
  //   List lang = widget.consultant['languages_Spoken'];
  //   return lang
  //           .map(
  //             (e) => Visibility(
  //               visible: lang.contains("") ? false : true,
  //               child: FilterChip(
  //                 label: Text(
  //                   camelize(e.toString()),
  //                   style: TextStyle(
  //                     color: AppColors.primaryColor,
  //                   ),
  //                 ),
  //                 padding: EdgeInsets.all(0),
  //                 onSelected: (bool value) {
  //                   widget.languageFilter(e.toString());
  //                 },
  //               ),
  //             ),
  //           )
  //           ?.toList() ??
  //       [];
  // }

  @override
  Widget build(BuildContext context) {
    // var consultantImage = widget.consultant['profile_picture'] == null
    //     ? null
    //     : Image.memory(base64Decode(
    //     widget.consultant['profile_picture']));
    return widget.isDirectCall
        ? Offstage(
            // offstage: status != 'Online' &&
            //     status != 'online' &&
            //     status != 'M' &&
            //     status != 'F',
            ///because now we are showing every consultant in live call also
            ///if not then uncomment this above 4 line
            offstage: false,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 4,
              color: AppColors.cardColor,
              child: InkWell(
                key: Key('affiliatedConsultant${widget.index}'),
                onTap: () async {
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  prefs.setString("selectedSpecality", widget.specality);
                  openTocDialogForFourPillars(
                    context,
                    on_Tap: Get.to(BookAppointmentForAffiliation(
                      doctor: widget.consultant,
                      companyName: widget.companyName,
                    )),
                    ontap_Available: true,
                    specnewScreen: true,
                  );
                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //         builder: (context) => BookAppointmentForAffiliation(
                  //               doctor: widget.consultant,
                  //               companyName: widget.companyName,
                  //             )));
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Stack(
                    children: [
                      Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Center(
                          child: Row(
                            children: [
                              Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 25, left: 25, right: 25, bottom: 5),
                                    child: CircleAvatar(
                                      radius: 50.0,
                                      backgroundImage: image == null ? null : image.image,
                                      backgroundColor: AppColors.primaryAccentColor,
                                    ),
                                  ),
                                  YetToArrive(status: status, yetToArriveStatus: currentAvailable),
                                  Visibility(
                                    visible: false,
                                    // (status.toLowerCase() == 'busy' ||
                                    //         status.toLowerCase() ==
                                    //             'offline') &&
                                    //     NxtAvailableTxt != '',
                                    child: FilterChip(
                                      label: Text(
                                        !NxtAvailableTxt.contains('no')
                                            ? camelize(NxtAvailableTxt)
                                            : 'Available at ' + NxtAvailableTxt,
                                        // camelize('Available at 06:00 PM'),
                                        style: TextStyle(
                                          color: AppColors.primaryAccentColor.withOpacity(0.9),
                                        ),
                                      ),
                                      padding: EdgeInsets.all(0),
                                      backgroundColor: Colors.lightGreenAccent.withOpacity(0.3),
                                      onSelected: (bool value) {},
                                    ),
                                  ),
                                ],
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        camelize(widget.consultant['name'].toString()),
                                        style: TextStyle(
                                          letterSpacing: 2.0,
                                          color: AppColors.primaryAccentColor,
                                        ),
                                      ),
                                      experienceYearsWidget(
                                          widget.consultant['experience'].toString()),
                                      SmoothStarRating(
                                        allowHalfRating: false,
                                        onRated: (v) {},
                                        starCount: 5,
                                        rating: widget.consultant['ratings'],
                                        size: 20.0,
                                        isReadOnly: true,
                                        color: Colors.amberAccent,
                                        borderColor: Colors.grey,
                                        spacing: 0.0,
                                      ),
                                      Wrap(
                                        direction: Axis.horizontal,
                                        // children: specialities(),
                                        children: _finetuned_specialities(),
                                        runSpacing: 0,
                                        spacing: 8,
                                      ),
                                      Visibility(
                                        visible: widget.consultant["languages_Spoken"] == null
                                            ? false
                                            : true,
                                        child: Wrap(
                                          children: languages(),
                                          runSpacing: 0,
                                          spacing: 8,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        NxtAvailableWidget(status: status, NxtAvailableTxt: NxtAvailableTxt),
                        SizedBox(
                          height: 4.0,
                        ),
                      ]),
                      banner()
                    ],
                  ),
                ),
              ),
            ),
          )
        : Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 4,
            color: AppColors.cardColor,
            child: InkWell(
              key: Key('affiliatedConsultant${widget.index}'),
              onTap: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.setString("selectedSpecality", widget.specality);
                Get.to(
                  BookAppointmentForAffiliation(
                    doctor: widget.consultant,
                    companyName: widget.companyName,
                  ),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Stack(
                  children: [
                    Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Center(
                        child: Row(
                          children: [
                            Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 25, left: 25, right: 25, bottom: 5),
                                  child: CircleAvatar(
                                    radius: 50.0,
                                    backgroundImage: image == null ? null : image.image,
                                    backgroundColor: AppColors.primaryAccentColor,
                                  ),
                                ),
                                Visibility(
                                  visible: false,
                                  child: YetToArrive(status: status),
                                ),
                                Visibility(
                                  visible: false,
                                  // (status.toLowerCase() == 'busy' ||
                                  //         status.toLowerCase() ==
                                  //             'offline') &&
                                  //     NxtAvailableTxt != '',
                                  child: FilterChip(
                                    label: Text(
                                      !NxtAvailableTxt.contains('no')
                                          ? camelize(NxtAvailableTxt)
                                          : 'Available at ' + NxtAvailableTxt,
                                      // camelize('Available at 06:00 PM'),
                                      style: TextStyle(
                                        color: AppColors.primaryAccentColor.withOpacity(0.9),
                                      ),
                                    ),
                                    padding: EdgeInsets.all(0),
                                    backgroundColor: Colors.lightGreenAccent.withOpacity(0.3),
                                    onSelected: (bool value) {},
                                  ),
                                ),
                              ],
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      camelize(widget.consultant['name'].toString()),
                                      style: TextStyle(
                                        letterSpacing: 2.0,
                                        color: AppColors.primaryAccentColor,
                                      ),
                                    ),
                                    experienceYearsWidget(
                                        widget.consultant['experience'].toString()),
                                    SmoothStarRating(
                                      allowHalfRating: false,
                                      onRated: (v) {},
                                      starCount: 5,
                                      rating: widget.consultant['ratings'],
                                      size: 20.0,
                                      isReadOnly: true,
                                      color: Colors.amberAccent,
                                      borderColor: Colors.grey,
                                      spacing: 0.0,
                                    ),
                                    Wrap(
                                      direction: Axis.horizontal,
                                      // children: specialities(),
                                      children: _finetuned_specialities(),
                                      runSpacing: 0,
                                      spacing: 8,
                                    ),
                                    Visibility(
                                      visible: widget.consultant["languages_Spoken"] == null
                                          ? false
                                          : true,
                                      child: Wrap(
                                        children: languages(),
                                        runSpacing: 0,
                                        spacing: 8,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Visibility(
                        visible: false,
                        child: NxtAvailableWidget(status: status, NxtAvailableTxt: NxtAvailableTxt),
                      ),
                      SizedBox(
                        height: 4.0,
                      ),
                    ]),
                    banner()
                  ],
                ),
              ),
            ),
          );
  }
}
