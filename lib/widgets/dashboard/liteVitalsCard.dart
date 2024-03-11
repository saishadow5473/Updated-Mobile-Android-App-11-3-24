// import 'package:flutter/material.dart';
// import 'package:ihl/constants/cardTheme.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:ihl/widgets/dashboard/badge.dart';
// import 'package:intl/intl.dart';
//
// Map theme = cardTheme1;
//
// /// Dashboard card (pass data, uidata, vitalType) 😁😁
// // ignore: must_be_immutable
// class VitalCard extends StatelessWidget {
//   Map uiData;
//   String vitalType;
//   List data;
//
//   VitalCard({this.uiData, this.data, this.vitalType});
//
//   @override
//   Widget build(BuildContext context) {
//     var color;
//     double width = MediaQuery.of(context).size.width;
//     if (width < 600) {
//       width = 500;
//     }
//     if (data != null) {
//       if (data.isNotEmpty) {
//         if (data[0]['value'] == 'NaN' && data[0]['status'] == "null") {
//           data = null;
//         }
//       }
//     }
//     if (data == null || data.isEmpty) {
//       data = null;
//       color = Colors.black.withOpacity(0.5);
//     } else {
//       color = theme['text'][data.last['status']];
//     }
//     // if(uiData['acr'] == "PROTEIN") {
//     //   color = theme['text'][data.last['proteinStatus']];
//     // }
//     // if(uiData['acr'] == "ECW") {
//     //   color = theme['text'][data.last['ecwStatus']];
//     // }
//     // if(uiData['acr'] == "ICW") {
//     //   color = theme['text'][data.last['icwStatus']];
//     // }
//     // if(uiData['acr'] == "MINERAL") {
//     //   color = theme['text'][data.last['mineralStatus']];
//     // }
//     // if(uiData['acr'] == "SMM") {
//     //   color = theme['text'][data.last['smmStatus']];
//     // }
//     // if(uiData['acr'] == "BFM") {
//     //   color = theme['text'][data.last['bfmStatus']];
//     // }
//     // if(uiData['acr'] == "BCM") {
//     //   color = theme['text'][data.last['bcmStatus']];
//     // }
//     // if(uiData['acr'] == "WAIST HIP") {
//     //   color = theme['text'][data.last['waistHipStatus']];
//     // }
//     // if(uiData['acr'] == "PBF") {
//     //   color = theme['text'][data.last['pbfStatus']];
//     // }
//     // if(uiData['acr'] == "WAIST HEIGHT") {
//     //   color = theme['text'][data.last['waistHeightStatus']];
//     // }
//     // if(uiData['acr'] == "VF") {
//     //   color = theme['text'][data.last['vfStatus']];
//     // }
//     // if(uiData['acr'] == "BMR") {
//     //   color = theme['text'][data.last['bmrStatus']];
//     // }
//     // if(uiData['acr'] == "BMC") {
//     //   color = theme['text'][data.last['bomcStatus']];
//     // }
//     color ??= Colors.blueAccent;
//
//     return IgnorePointer(
//       ignoring: data == null,
//       child: Stack(
//         children: <Widget>[
//           Card(
//             margin: EdgeInsets.all(2),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(1.0),
//             ),
//             elevation: 5,
//             color: data != null ? Colors.white : Colors.grey[200],
//             child: InkWell(
//               borderRadius: BorderRadius.circular(10.0),
//               onTap: () {
//                 List tempList = [];
//                 List optimizedVitalData = [];
//                 var date;
//                 for (var i = 0; i < data.length; i++) {
//                   date = (data[i]['date']);
//                   final DateFormat formatter =
//                       DateFormat("yyyy-MM-dd HH:mm:ss");
//                   final String formatted = formatter.format(date);
//                   tempList.add(formatted);
//                   if (tempList.length > 1) {
//                     if (tempList[i - 1] == tempList[i]) {
//                       i = i++;
//                     } else {
//                       optimizedVitalData.add(data[i]);
//                     }
//                   } else {
//                     optimizedVitalData.add(data[i]);
//                   }
//                 }
//                 Map arg = {
//                   'vitalType': vitalType,
//                   'status': optimizedVitalData.last['status'],
//                   'value': optimizedVitalData.last['value'].toString(),
//                   'data': optimizedVitalData
//                 };
//                 Navigator.pushNamed(context, 'vital_screen', arguments: arg);
//               },
//               splashColor: color,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: <Widget>[
//                   Padding(
//                     padding: const EdgeInsets.only(top: 8.0),
//                     child: Row(
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                       children: <Widget>[
//                         Hero(
//                           tag: vitalType + 'screenTitle',
//                           child: Text(
//                             uiData['acr'],
//                             style: TextStyle(
//                               color: color,
//                               fontSize: 20 * width / 600,
//                             ),
//                           ),
//                         ),
//                         SizedBox(
//                           width: 8,
//                         ),
//                         Hero(
//                           tag: vitalType + 'screen',
//                           child: Image.asset(
//                             uiData['icon'],
//                             height: theme['icon']['size'] * width / 600,
//                             fit: BoxFit.contain,
//                             width: theme['icon']['size'] * width / 700,
//                             color: color,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Expanded(
//                     flex: 1,
//                     child: Container(),
//                   ),
//                   // SizedBox(
//                   //   height: 10,
//                   // ),
//                   RichText(
//                     overflow: TextOverflow.ellipsis,
//                     text: TextSpan(children: [
//                       TextSpan(
//                           text: data == null
//                               ? 'N/A'
//                               : data.last['value'].toString(),
//                           style: TextStyle(
//                               color: color,
//                               fontWeight: FontWeight.bold,
//                               fontSize: 18.0 * width / 500)),
//                       TextSpan(
//                         text: data == null ? '' : uiData['unit'],
//                         style:
//                             TextStyle(color: color, fontSize: 1 * width / 500),
//                       )
//                     ]),
//                   ),
//                   // SizedBox(
//                   //   height: 20,
//                   // ),
//                   Expanded(
//                     flex: 1,
//                     child: Container(),
//                   ),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: <Widget>[
//                       Flexible(
//                         child:
//                             // uiData['acr'] == "PROTEIN" ? Text(
//                             //   data == null ? 'N/A' : data.last['proteinStatus'],
//                             //   style: TextStyle(
//                             //       color: color, fontSize: 15 * width / 500),
//                             //   overflow: TextOverflow.ellipsis,
//                             // )
//                             //     : uiData['acr'] == "ECW" ? Text(
//                             //   data == null ? 'N/A' : data.last['ecwStatus'],
//                             //   style: TextStyle(
//                             //       color: color, fontSize: 15 * width / 500),
//                             //   overflow: TextOverflow.ellipsis,
//                             // )
//                             //     : uiData['acr'] == "ICW" ? Text(
//                             //   data == null ? 'N/A' : data.last['icwStatus'],
//                             //   style: TextStyle(
//                             //       color: color, fontSize: 15 * width / 500),
//                             //   overflow: TextOverflow.ellipsis,
//                             // )
//                             //     : uiData['acr'] == "MINERAL" ? Text(
//                             //   data == null ? 'N/A' : data.last['mineralStatus'],
//                             //   style: TextStyle(
//                             //       color: color, fontSize: 15 * width / 500),
//                             //   overflow: TextOverflow.ellipsis,
//                             // )
//                             //     : uiData['acr'] == "SMM" ? Text(
//                             //   data == null ? 'N/A' : data.last['smmStatus'],
//                             //   style: TextStyle(
//                             //       color: color, fontSize: 15 * width / 500),
//                             //   overflow: TextOverflow.ellipsis,
//                             // )
//                             //     : uiData['acr'] == "BFM" ? Text(
//                             //   data == null ? 'N/A' : data.last['bfmStatus'],
//                             //   style: TextStyle(
//                             //       color: color, fontSize: 15 * width / 500),
//                             //   overflow: TextOverflow.ellipsis,
//                             // )
//                             //     : uiData['acr'] == "BCM" ? Text(
//                             //   data == null ? 'N/A' : data.last['bcmStatus'],
//                             //   style: TextStyle(
//                             //       color: color, fontSize: 15 * width / 500),
//                             //   overflow: TextOverflow.ellipsis,
//                             // )
//                             //     : uiData['acr'] == "WAIST HIP" ? Text(
//                             //   data == null ? 'N/A' : data.last['waistHipStatus'],
//                             //   style: TextStyle(
//                             //       color: color, fontSize: 15 * width / 500),
//                             //   overflow: TextOverflow.ellipsis,
//                             // )
//                             //     : uiData['acr'] == "PBF" ? Text(
//                             //   data == null ? 'N/A' : data.last['pbfStatus'],
//                             //   style: TextStyle(
//                             //       color: color, fontSize: 15 * width / 500),
//                             //   overflow: TextOverflow.ellipsis,
//                             // )
//                             //     : uiData['acr'] == "WAIST HEIGHT" ? Text(
//                             //   data == null ? 'N/A' : data.last['waistHeightStatus'],
//                             //   style: TextStyle(
//                             //       color: color, fontSize: 15 * width / 500),
//                             //   overflow: TextOverflow.ellipsis,
//                             // )
//                             //     : uiData['acr'] == "VF" ? Text(
//                             //   data == null ? 'N/A' : data.last['vfStatus'],
//                             //   style: TextStyle(
//                             //       color: color, fontSize: 15 * width / 500),
//                             //   overflow: TextOverflow.ellipsis,
//                             // )
//                             //     : uiData['acr'] == "BMR" ? Text(
//                             //   data == null ? 'N/A' : data.last['bmrStatus'],
//                             //   style: TextStyle(
//                             //       color: color, fontSize: 15 * width / 500),
//                             //   overflow: TextOverflow.ellipsis,
//                             // )
//                             //     : uiData['acr'] == "BMC" ? Text(
//                             //   data == null ? 'N/A' : data.last['bomcStatus'],
//                             //   style: TextStyle(
//                             //       color: color, fontSize: 15 * width / 500),
//                             //   overflow: TextOverflow.ellipsis,
//                             // )
//                             //     :
//                             Text(
//                           data == null ? 'N/A' : data.last['status'],
//                           style: TextStyle(
//                               color: color, fontSize: 14 * width / 400),
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ),
//                       // Icon(
//                       //   FontAwesomeIcons.chartBar,
//                       //   color: color,
//                       // ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           Positioned(
//             child: Badge(
//               status: data == null ? 'N/A' : data.last['status'],
//               color: color,
//             ),
//             right: 0,
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ihl/constants/cardTheme.dart';
import 'package:ihl/new_design/app/utils/appColors.dart';
import 'package:ihl/widgets/dashboard/badge.dart' as badge;
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

Map theme = cardTheme1;

/// Dashboard card (pass data, uidata, vitalType) 😁😁
// ignore: must_be_immutable
class VitalCard extends StatelessWidget {
  Map uiData;
  String vitalType;
  List data;

  VitalCard({this.uiData, this.data, this.vitalType});

  @override
  Widget build(BuildContext context) {
    var color;
    double width = MediaQuery.of(context).size.width;
    if (width < 600) {
      width = 500;
    }
    if (data != null) {
      if (data.isNotEmpty) {
        if (data[0]['value'] == 'NaN' && data[0]['status'] == "null") {
          data = null;
        }
      }
    }
    if (data == null || data.isEmpty) {
      data = null;
      color = Colors.black.withOpacity(0.5);
    } else {
      if (uiData['acr'] == 'BMR')
        color = AppColors.primaryColor;
      else
        color = theme['text'][data.last['status']];
    }
    // if(uiData['acr'] == "PROTEIN") {
    //   color = theme['text'][data.last['proteinStatus']];
    // }
    // if(uiData['acr'] == "ECW") {
    //   color = theme['text'][data.last['ecwStatus']];
    // }
    // if(uiData['acr'] == "ICW") {
    //   color = theme['text'][data.last['icwStatus']];
    // }
    // if(uiData['acr'] == "MINERAL") {
    //   color = theme['text'][data.last['mineralStatus']];
    // }
    // if(uiData['acr'] == "SMM") {
    //   color = theme['text'][data.last['smmStatus']];
    // }
    // if(uiData['acr'] == "BFM") {
    //   color = theme['text'][data.last['bfmStatus']];
    // }
    // if(uiData['acr'] == "BCM") {
    //   color = theme['text'][data.last['bcmStatus']];
    // }
    // if(uiData['acr'] == "WAIST HIP") {
    //   color = theme['text'][data.last['waistHipStatus']];
    // }
    // if(uiData['acr'] == "PBF") {
    //   color = theme['text'][data.last['pbfStatus']];
    // }
    // if(uiData['acr'] == "WAIST HEIGHT") {
    //   color = theme['text'][data.last['waistHeightStatus']];
    // }
    // if(uiData['acr'] == "VF") {
    //   color = theme['text'][data.last['vfStatus']];
    // }
    // if(uiData['acr'] == "BMR") {
    //   color = theme['text'][data.last['bmrStatus']];
    // }
    // if(uiData['acr'] == "BMC") {
    //   color = theme['text'][data.last['bomcStatus']];
    // }
    color ??= Colors.blueAccent;

    return IgnorePointer(
      ignoring: data == null,
      child: Stack(
        children: <Widget>[
          Card(
            margin: EdgeInsets.all(7),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            elevation: 2,
            color: data != null ? Colors.white : Colors.grey[200],
            child: InkWell(
              borderRadius: BorderRadius.circular(10.0),
              onTap: () {
                List tempList = [];
                List optimizedVitalData = [];
                var date;
                for (var i = 0; i < data.length; i++) {
                  date = (data[i]['date']);
                  final DateFormat formatter = DateFormat("yyyy-MM-dd HH:mm:ss");
                  final String formatted = formatter.format(date);
                  tempList.add(formatted);
                  if (tempList.length > 1) {
                    if (tempList[i - 1] == tempList[i]) {
                      i = i++;
                    } else {
                      optimizedVitalData.add(data[i]);
                    }
                  } else {
                    optimizedVitalData.add(data[i]);
                  }
                }
                Map arg = {
                  'vitalType': vitalType,
                  'status': optimizedVitalData.last['status'],
                  'value': optimizedVitalData.last['value'].toString(),
                  'data': optimizedVitalData
                };
                // var xyzabc = arg;
                // print(xyzabc);
                // Navigator.pushNamed(context, 'vital_screen', arguments: arg);
                Navigator.pushNamed(context, "vital_screen", arguments: arg);
              },
              splashColor: color,
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Hero(
                          tag: vitalType + 'screenTitle',
                          child: Text(
                            uiData['acr'],
                            style: TextStyle(
                              color: color,
                              // fontSize: 14 * width / 500,
                              fontSize: 18.sp,
                            ),
                          ),
                        ),
                        Hero(
                          tag: vitalType + 'screen',
                          child: Image.asset(
                            uiData['icon'],
                            height: theme['icon']['size'] * width / 500,
                            fit: BoxFit.contain,
                            width: theme['icon']['size'] * width / 500,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),
                    // Expanded(
                    //   flex: 1,
                    //   child: Container(),
                    // ),
                    RichText(
                      overflow: TextOverflow.ellipsis,
                      text: TextSpan(children: [
                        TextSpan(
                            text: data == null ? 'N/A' : data.last['value'].toString(),
                            style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.bold,
                              // fontSize: 22.0 * width / 500),
                              fontSize: 20.sp,
                              // fontSize: ScUtil().setSp(20),
                            )),
                        TextSpan(
                          text: data == null ? '' : uiData['unit'],
                          style: TextStyle(
                            color: color,

                            // fontSize: 14 * width / 500
                            fontSize: 15.sp,
                          ),
                        )
                      ]),
                    ),
                    SizedBox(height: 2.h),

                    // Expanded(
                    //   flex: 1,
                    //   child: Container(),
                    // ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Flexible(
                          child:
                              // uiData['acr'] == "PROTEIN" ? Text(
                              //   data == null ? 'N/A' : data.last['proteinStatus'],
                              //   style: TextStyle(
                              //       color: color, fontSize: 15 * width / 500),
                              //   overflow: TextOverflow.ellipsis,
                              // )
                              //     : uiData['acr'] == "ECW" ? Text(
                              //   data == null ? 'N/A' : data.last['ecwStatus'],
                              //   style: TextStyle(
                              //       color: color, fontSize: 15 * width / 500),
                              //   overflow: TextOverflow.ellipsis,
                              // )
                              //     : uiData['acr'] == "ICW" ? Text(
                              //   data == null ? 'N/A' : data.last['icwStatus'],
                              //   style: TextStyle(
                              //       color: color, fontSize: 15 * width / 500),
                              //   overflow: TextOverflow.ellipsis,
                              // )
                              //     : uiData['acr'] == "MINERAL" ? Text(
                              //   data == null ? 'N/A' : data.last['mineralStatus'],
                              //   style: TextStyle(
                              //       color: color, fontSize: 15 * width / 500),
                              //   overflow: TextOverflow.ellipsis,
                              // )
                              //     : uiData['acr'] == "SMM" ? Text(
                              //   data == null ? 'N/A' : data.last['smmStatus'],
                              //   style: TextStyle(
                              //       color: color, fontSize: 15 * width / 500),
                              //   overflow: TextOverflow.ellipsis,
                              // )
                              //     : uiData['acr'] == "BFM" ? Text(
                              //   data == null ? 'N/A' : data.last['bfmStatus'],
                              //   style: TextStyle(
                              //       color: color, fontSize: 15 * width / 500),
                              //   overflow: TextOverflow.ellipsis,
                              // )
                              //     : uiData['acr'] == "BCM" ? Text(
                              //   data == null ? 'N/A' : data.last['bcmStatus'],
                              //   style: TextStyle(
                              //       color: color, fontSize: 15 * width / 500),
                              //   overflow: TextOverflow.ellipsis,
                              // )
                              //     : uiData['acr'] == "WAIST HIP" ? Text(
                              //   data == null ? 'N/A' : data.last['waistHipStatus'],
                              //   style: TextStyle(
                              //       color: color, fontSize: 15 * width / 500),
                              //   overflow: TextOverflow.ellipsis,
                              // )
                              //     : uiData['acr'] == "PBF" ? Text(
                              //   data == null ? 'N/A' : data.last['pbfStatus'],
                              //   style: TextStyle(
                              //       color: color, fontSize: 15 * width / 500),
                              //   overflow: TextOverflow.ellipsis,
                              // )
                              //     : uiData['acr'] == "WAIST HEIGHT" ? Text(
                              //   data == null ? 'N/A' : data.last['waistHeightStatus'],
                              //   style: TextStyle(
                              //       color: color, fontSize: 15 * width / 500),
                              //   overflow: TextOverflow.ellipsis,
                              // )
                              //     : uiData['acr'] == "VF" ? Text(
                              //   data == null ? 'N/A' : data.last['vfStatus'],
                              //   style: TextStyle(
                              //       color: color, fontSize: 15 * width / 500),
                              //   overflow: TextOverflow.ellipsis,
                              // )
                              //     : uiData['acr'] == "BMR" ? Text(
                              //   data == null ? 'N/A' : data.last['bmrStatus'],
                              //   style: TextStyle(
                              //       color: color, fontSize: 15 * width / 500),
                              //   overflow: TextOverflow.ellipsis,
                              // )
                              //     : uiData['acr'] == "BMC" ? Text(
                              //   data == null ? 'N/A' : data.last['bomcStatus'],
                              //   style: TextStyle(
                              //       color: color, fontSize: 15 * width / 500),
                              //   overflow: TextOverflow.ellipsis,
                              // )
                              //     :
                              Visibility(
                            visible: uiData['acr'] != "BMR",
                            child: Text(
                              data == null ? 'N/A' : data.last['status'],
                              style: TextStyle(
                                color: color,
                                fontSize: 16.sp,
                                // fontSize: 14 * width / 500
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        Visibility(
                          visible: uiData['acr'] != "BMR",

                          child: Icon(
                            FontAwesomeIcons.chartBar,
                            color: color,
                            size: 20.sp,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            child: badge.Badge(
              status: data == null ? 'N/A' : data.last['status'],
              color: color,
            ),
            right: 0,
          ),
        ],
      ),
    );
  }
}
