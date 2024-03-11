import 'dart:convert';
import 'dart:math';

import 'package:connectanum/connectanum.dart';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:ihl/constants/api.dart';
import 'package:ihl/constants/app_texts.dart';
import 'package:ihl/utils/SpUtil.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/views/teleconsultation/specialityType.dart';
import 'package:ihl/views/teleconsultation/viewallneeds.dart';
import 'package:ihl/widgets/ScrollessBasicPageUI.dart';
import 'package:ihl/widgets/offline_widget.dart';
import 'package:ihl/widgets/teleconsulation/book_appointment.dart';
import 'package:ihl/widgets/teleconsulation/selectConsultantCard.dart';
import 'package:strings/strings.dart';
import '../../new_design/presentation/Widgets/dashboardWidgets/affiliation_widgets.dart';

// ignore: must_be_immutable
class SelectConsutantScreen extends StatefulWidget {
  final bool liveCall;
  Map arg;
  bool backNavi;

  SelectConsutantScreen({@required this.arg, this.liveCall, this.backNavi});

  @override
  _SelectConsutantScreenState createState() => _SelectConsutantScreenState();
}

class _SelectConsutantScreenState extends State<SelectConsutantScreen> {
  http.Client _client = http.Client(); //3gb
  var nonAffiliatedConsultants = [];
  List results = [];
  List languageFilters = [];
  List consultantId = [];
  bool _isLoading = false;
  bool _isNoConsultant = false;
  var docStatus;
  Session session1;
  @override
  void initState() {
    if (widget.backNavi == null) {
      widget.backNavi = false;
    }
    super.initState();
    filterNonAffiliatedConsultants();
    results = widget.arg['consultant_list'];
    results ??= [];

    if (widget.liveCall == true) {
      _isLoading = true;
      onlineFilter();
      SpUtil.putObject('selectConsultantTypeData', widget.arg);
    }

    // for (int i = 0; i <= results.length - 1; i++) {
    //   consultantId.add(results[i]['ihl_consultant_id']);
    // }
    // getConsultantImageURL();
  }

  filterNonAffiliatedConsultants() async {
    bool sso = UpdatingColorsBasedOnAffiliations.ssoAffiliation != null &&
        UpdatingColorsBasedOnAffiliations.ssoAffiliation["affiliation_unique_name"] != null;
    var consultants = widget.arg['consultant_list'];
    if (!sso) {
      for (int i = 0; i < consultants.length; i++) {
        // if (widget.liveCall == false) {
        //   var imageValue = await getConsultantImageURL(consultants[i]['vendor_id'] == "GENIX"
        //       ? [consultants[i]['vendor_consultant_id'], consultants[i]['vendor_id']]
        //       : [consultants[i]['ihl_consultant_id'], consultants[i]['vendor_id']]);
        //   consultants[i]['profile_picture'] = imageValue;
        // }
        if (consultants[i]['affilation_excusive_data'] == null ||
            consultants[i]['exclusive_only'] == false) {
          if (consultants[i]["ihl_consultant_id"] != "b82fd0384bba473086aaae70a7222a55" &&
              consultants[i]["ihl_consultant_id"] != 'b82fd0384bba473086aaae70a7222a17') {
            nonAffiliatedConsultants.add(consultants[i]);
          }
        } else if (consultants[i]['affilation_excusive_data'] != null) {
          if (consultants[i]['affilation_excusive_data'].length == 0) {
            nonAffiliatedConsultants.add(consultants[i]);
          }
        } else if (consultants[i]['affilation_excusive_data'] != null) {
          if (consultants[i]['affilation_excusive_data'].length != 0) {
            if (consultants[i]['affilation_excusive_data']['affilation_array'].length != 0 &&
                consultants[i]['exclusive_only'] == false) {
              nonAffiliatedConsultants.add(consultants[i]);
            }
          }
        } else if (consultants[i]['affilation_excusive_data'] != null) {
          if (consultants[i]['affilation_excusive_data'].length != 0) {
            if (consultants[i]['affilation_excusive_data']['affilation_array'].length == 0) {
              nonAffiliatedConsultants.add(consultants[i]);
            }
          }
        }
      }
    } else {
      for (int i = 0; i < consultants.length; i++) {
        if (consultants[i]["ihl_consultant_id"] != "b82fd0384bba473086aaae70a7222a55" &&
            consultants[i]["ihl_consultant_id"] != 'b82fd0384bba473086aaae70a7222a17') {
          if (consultants[i]['affilation_excusive_data'] != null) {
            if (consultants[i]['affilation_excusive_data'].length != 0) {
              if (consultants[i]['affilation_excusive_data']['affilation_array'].length != 0) {
                nonAffiliatedConsultants.add(consultants[i]);
              }
            }
          } else if (consultants[i]['affilation_excusive_data'] != null) {
            if (consultants[i]['affilation_excusive_data'].length != 0) {
              if (consultants[i]['affilation_excusive_data']['affilation_array'].length == 0) {
                nonAffiliatedConsultants.add(consultants[i]);
              }
            }
          }
        }
      }
    }
    if (sso) {
      nonAffiliatedConsultants.removeWhere((element) {
        bool value = false;
        List affiData = [];
        affiData = element['affilation_excusive_data']['affilation_array'];
        if (affiData != null) {
          for (var e in affiData) {
            value = e["affilation_unique_name"] ==
                UpdatingColorsBasedOnAffiliations.ssoAffiliation["affiliation_unique_name"];
          }
        }
        return !value;
      });
    }
    onlineFilter();
    print(nonAffiliatedConsultants);
  }

  Future<String> getConsultantImageURL(var map) async {
    try {
      var bodyGenix = jsonEncode(<String, dynamic>{
        'vendorIdList': [map[0]],
        "consultantIdList": [""],
      });
      var bodyIhl = jsonEncode(<String, dynamic>{
        'consultantIdList': [map[0]],
        "vendorIdList": [""],
      });
      final response = await _client.post(
        Uri.parse(API.iHLUrl + "/consult/profile_image_fetch"),
        headers: {
          'Content-Type': 'application/json',
          'ApiToken': '${API.headerr['ApiToken']}',
          'Token': '${API.headerr['Token']}',
        },
        body: map[1] == "GENIX" ? bodyGenix : bodyIhl,
      );
      if (response.statusCode == 200) {
        var imageOutput = json.decode(response.body);
        var consultantIDAndImage =
            map[1] == 'GENIX' ? imageOutput["genixbase64list"] : imageOutput["ihlbase64list"];
        for (var i = 0; i < consultantIDAndImage.length; i++) {
          if (map[0] == consultantIDAndImage[i]['consultant_ihl_id']) {
            var base64Image = consultantIDAndImage[i]['base_64'].toString();
            base64Image = base64Image.replaceAll('data:image/jpeg;base64,', '');
            base64Image = base64Image.replaceAll('}', '');
            base64Image = base64Image.replaceAll('data:image/jpegbase64,', '');
            var image;
            var consultantImage;
            if (this.mounted) {
              consultantImage = base64Image;
              // setState(() {
              //   consultantImage = base64Image;
              // });
            }
            if (consultantImage == null || consultantImage == "") {
              //widget.consultant['profile_picture'] = AvatarImage.defaultUrl;
              // image = Image.memory(
              //     base64Decode(AvatarImage.defaultUrl));

              //finalResult['image']=image;
              return AvatarImage.defaultUrl;
            } else {
              //widget.consultant['profile_picture'] = consultantImage;
              image = Image.memory(base64Decode(consultantImage));
              // var finalResult=new Map();
              // finalResult['profile_picture']=;
              // finalResult['image']=image;
              return consultantImage;
            }
          }
        }
        return AvatarImage.defaultUrl;
      } else {
        return AvatarImage.defaultUrl;
      }
    } catch (e) {
      print(e.toString());
      return AvatarImage.defaultUrl;
    }
  }

  void dispose() {
    // ignore: unrelated_type_equality_checks
    if (session1 != null) {
      session1.close();
    }
    super.dispose();
  }

  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void onlineFilter() async {
    // List filteredResults = [];
    for (int i = 0; i <= nonAffiliatedConsultants.length - 1; i++) {
      docStatus = await httpStatus(nonAffiliatedConsultants[i]['ihl_consultant_id']);
      nonAffiliatedConsultants[i]['sortStatus'] = docStatus;
      //
      // var imageValue = await getConsultantImageURL(
      //     nonAffiliatedConsultants[i]['vendor_id'] == "GENIX"
      //         ? [
      //             nonAffiliatedConsultants[i]['vendor_consultant_id'],
      //             nonAffiliatedConsultants[i]['vendor_id']
      //           ]
      //         : [
      //             nonAffiliatedConsultants[i]['ihl_consultant_id'],
      //             nonAffiliatedConsultants[i]['vendor_id']
      //           ]);
      // nonAffiliatedConsultants[i]['profile_picture'] = imageValue;

      // if (docStatus == 'Online' || docStatus == 'online' || docStatus == 'M' || docStatus == 'F') {
      //   //Uncommenet this commented func if need of online consultant on top and offline consultant next to that in same list
      //   filteredResults.insert(0, nonAffiliatedConsultants[i]);
      //   //filteredResults.add(nonAffiliatedConsultants[i]);
      //   _isNoConsultant = true;
      // } else {
      //   //Uncommenet this commented func if need of online consultant on top and offline consultant next to that in same list
      //   filteredResults.add(nonAffiliatedConsultants[i]);
      //   //filteredResults.add(nonAffiliatedConsultants[i]);
      // }
    }
    final statusOrder = {'Online': 0, 'M': 1, 'F': 2};
    nonAffiliatedConsultants.sort((a, b) {
      final orderA = statusOrder[a['sortStatus']];
      final orderB = statusOrder[b['sortStatus']];

      if (orderA != null && orderB != null) {
        return orderA.compareTo(orderB);
      } else if (orderA != null) {
        return -1; // a should come before b
      } else if (orderB != null) {
        return 1; // b should come before a
      } else {
        return 0; // a and b are not in the specified statuses
      }
    });
    if (this.mounted) {
      setState(() {
        // nonAffiliatedConsultants = filteredResults;

        // nonAffiliatedConsultants.length != 0 ??
        //     nonAffiliatedConsultants
        //         .sort((a, b) => a["name"].compareTo(b["name"]));
        _isLoading = false;
      });
    }
  }

  Future<String> httpStatus(var consultantId) async {
    var status;
    final response = await _client.post(
      Uri.parse(API.iHLUrl + '/consult/getConsultantLiveStatus'),
      body: jsonEncode(<String, dynamic>{
        "consultant_id": [consultantId]
      }),
    );
    if (response.statusCode == 200) {
      if (response.body != '"[]"') {
        var parsedString = response.body.replaceAll('&quot', '"');
        var parsedString1 = parsedString.replaceAll(";", "");
        var parsedString2 = parsedString1.replaceAll('"[', '[');
        var parsedString3 = parsedString2.replaceAll(']"', ']');
        var finalOutput = json.decode(parsedString3);
        var doctorId = consultantId;

        if (doctorId == finalOutput[0]['consultant_id']) {
          if (this.mounted) {
            setState(() {
              status = camelize(finalOutput[0]['status'].toString());
            });
          }
        }
      } else {}
    } else {
      print('responce failure');
    }

    return status;
  }

  // var consultantIDAndImage = [];
  // var base64Image;
  // var consultantImage;

  // Future getConsultantImageURL() async {
  //   final response = await http.post(
  //     API.iHLUrl+"/consult/profile_image_fetch",
  //     body: jsonEncode(<String, dynamic>{
  //       'consultantIdList': consultantId,
  //     }),
  //   );
  //   if (response.statusCode == 200) {
  //     List imageOutput = json.decode(response.body);
  //     consultantIDAndImage = imageOutput;
  //     for (var i = 0; i < consultantIDAndImage.length; i++) {
  //       if (results[i]['ihl_consultant_id'] ==
  //           consultantIDAndImage[i]['consultant_ihl_id']) {
  //         //dekh je ike
  //         base64Image = consultantIDAndImage[i]['base_64'].toString();
  //         base64Image = base64Image.replaceAll('data:image/jpeg;base64,', '');
  //         base64Image = base64Image.replaceAll('}', '');
  //         base64Image = base64Image.replaceAll('data:image/jpegbase64,', '');
  //         if (this.mounted) {
  //           setState(() {
  //             // consultantImage = imageFromBase64String(base64Image);
  //             consultantImage = base64Image;
  //           });
  //         }
  //         if (consultantImage == null || consultantImage == "") {
  //           results[i]['profile_picture'] = AvatarImage.defaultUrl;
  //           consultantImageToSend = Image.memory(base64Decode(
  //               results[i]['profile_picture']));
  //         } else {
  //           results[i]['profile_picture'] = consultantImage;
  //           consultantImageToSend = Image.memory(base64Decode(
  //               results[i]['profile_picture']));
  //         }
  //       }
  //     }
  //   } else {
  //     print(response.body);
  //   }
  // }

  void reset() {
    if (this.mounted) {
      setState(() {
        onlineFilter();
      });
    }
  }

  void updateLanguageFilter() {
    reset();
    if (languageFilters.length == 0) {
      return;
    }
    List filtered = [];
    for (var k in languageFilters) {
      for (int i = 0; i < nonAffiliatedConsultants.length; i++) {
        if (nonAffiliatedConsultants[i]['languages_Spoken'].contains(k)) {
          filtered.add(nonAffiliatedConsultants[i]);
        }
      }
    }
    if (this.mounted) {
      setState(() {
        nonAffiliatedConsultants = filtered;
      });
    }
  }

  void removeLanguageFilter(String lang) {
    languageFilters.remove(lang);
    updateLanguageFilter();
  }

  void filterByLanguage(String lang) {
    if (languageFilters.contains(lang)) {
      return;
    }
    languageFilters.add(lang);
    updateLanguageFilter();
  }

  bool rndtf() {
    Random rnd = Random();
    return rnd.nextBool();
  }

  Widget createCard(Map mp) {
    if (mp == null) {
      return Text('error!');
    }
    if (mp['availabilityStatus'] == null) {
      mp['availabilityStatus'] = 'Online';
      if (rndtf()) {
        mp['availabilityStatus'] = 'Busy';
      }
      if (rndtf()) {
        mp['availabilityStatus'] = 'Offline';
      }
    }
    if (!(mp['name'] is String) || mp['name'] == null) {
      mp['name'] = 'N/A';
    }
    if (!(mp['photo'] is String) || mp['photo'] == null) {
      mp['photo'] =
          'https://banner2.cleanpng.com/20180330/fhq/kisspng-font-awesome-computer-icons-user-doctor-of-medicin-exam-5abeb2f7be2d97.697048921522447095779.jpg';
    }
    if (mp['ratings'] is num) {
      mp['ratings'] = mp['ratings'] * 1.0;
    }
    if (mp['ratings'] is String) {
      mp['ratings'] = double.tryParse(mp['ratings']);
    }
    if (mp['ratings'] == null) {
      mp['ratings'] = 0.0;
    }
    mp['livecall'] = true;

    return SelectConsultantCard(
      mp,
      widget.arg['specality_name'].toString(),
      widget.arg['livecall'],
      languageFilter: filterByLanguage,
      isDirectCall: widget.liveCall,
    );
  }

  List<Widget> languages() {
    List lang = languageFilters;
    return lang
            .map(
              (e) => FilterChip(
                label: Text(
                  camelize(e.toString()),
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                backgroundColor: Colors.red,
                avatar: Icon(
                  Icons.cancel,
                  color: Colors.white,
                ),
                padding: EdgeInsets.all(0),
                onSelected: (bool value) {
                  removeLanguageFilter(e);
                },
              ),
            )
            .toList() ??
        [];
  }

  //for search implementation//
  final TextEditingController _typeAheadController = TextEditingController();
  // final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  FocusNode typeAheadFocus = new FocusNode();
  // for search implementation//

  @override
  Widget build(BuildContext context) {
    return ConnectivityWidgetWrapper(
      disableInteraction: true,
      offlineWidget: OfflineWidget(),
      child: WillPopScope(
        // ignore: missing_return
        onWillPop: () {
          if (widget.backNavi) {
            Get.off(ViewallTeleDashboard());
          } else {
            Navigator.pop(context);
          }
        },
        child: ScrollessBasicPageUI(
            appBar: Column(
              children: [
                SizedBox(
                  width: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // BackButton(
                    //   onPressed: () {
                    //     if(widget.backNavi!=null&&widget.backNavi){
                    //       Get.off(ViewallTeleDashboard());
                    //     }
                    //     else{
                    //       Navigator.pop(context);
                    //     }
                    //   },
                    //   color: Colors.white,
                    // ),
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios),
                      onPressed: () {
                        if (widget.backNavi != null && widget.backNavi) {
                          Get.off(ViewallTeleDashboard());
                        } else {
                          Navigator.pop(context);
                        }
                      }, //replaces the screen to Main dashboard
                      color: Colors.white,
                    ),
                    Flexible(
                      child: Text(
                        AppTexts.selectConsultant,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.white, fontSize: 22),
                      ),
                    ),
                    SizedBox(
                      width: 40,
                    )
                  ],
                ),
                Text(
                  widget.arg['specality_name'].toString().replaceAll('&amp;', '&'),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 8,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                  child: TypeAheadFormField(
                    textFieldConfiguration: TextFieldConfiguration(
                      focusNode: typeAheadFocus,
                      // cursorColor:
                      // HexColor(widget.mealsListData.startColor),
                      controller: this._typeAheadController,
                      cursorColor: Colors.white,
                      style: TextStyle(
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        enabledBorder: const OutlineInputBorder(
                          // width: 0.0 produces a thin "hairline" border
                          borderRadius: const BorderRadius.all(
                            const Radius.circular(30.0),
                          ),
                          borderSide: const BorderSide(
                            color: Colors.white,
                          ),
                        ),
                        labelStyle: //typeAheadFocus.hasPrimaryFocus
                            TextStyle(
                          color: Colors.white,
                        ),
                        //: TextStyle(),
                        hintStyle: TextStyle(
                          color: Colors.white,
                        ),

                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.white,
                            //     widget.mealsListData.startColor),
                          ),
                          borderRadius: const BorderRadius.all(
                            const Radius.circular(30.0),
                          ),
                        ),
                        border: new OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.white,
                          ),
                          borderRadius: const BorderRadius.all(
                            const Radius.circular(30.0),
                          ),
                        ),

                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        hintText: 'Search Consultants by Key words',
                        prefixIcon: Padding(
                          padding: const EdgeInsetsDirectional.only(start: 8, end: 8.0),
                          child: Icon(
                            Icons.search,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    suggestionsCallback: (pattern) async {
                      return await Consultants.getSuggestions(pattern);
                    },
                    itemBuilder: (context, suggestion) {
                      return ListTile(
                        title: Text(suggestion['name']),
                        subtitle: Text("${suggestion['consultant_speciality'][0]}"),
                        trailing: Text('₹ ${suggestion['consultation_fees']}'),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Container(
                            height: 50,
                            width: 50,
                            decoration:
                                BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(20))),
                            child: Image.memory(
                              base64Decode(AvatarImage.defaultUrl),
                            ),
                          ),
                        ),
                      );
                    },
                    transitionBuilder: (context, suggestionsBox, controller) {
                      return suggestionsBox;
                    },
                    onSuggestionSelected: (suggestion) async {
                      this._typeAheadController.text = '';
                      if (suggestion['vendor_id'] == 'GENIX') {
                        suggestion['livecall'] = false;
                      } else {
                        suggestion['livecall'] = widget.arg['livecall'];
                      }
                      // suggestion['livecall'] = widget.arg['livecall'];
                      suggestion['availabilityStatus'] =
                          await httpStatus(suggestion['ihl_consultant_id']);
                      Get.to(
                        BookAppointment(
                          doctor: suggestion,
                          specality: suggestion['consultant_speciality'],
                        ),
                      );
                    },
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please type any letter to search';
                      }
                      return null;
                    },
                    noItemsFoundBuilder: (value) {
                      return (_typeAheadController.text == '' ||
                              _typeAheadController.text.length == 0 ||
                              _typeAheadController.text == null)
                          ? Container()
                          : Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Column(
                                children: [
                                  Text(
                                    'No Consultant Found!',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: AppColors.appTextColor, fontSize: 18.0),
                                  ),
                                  // SizedBox(
                                  //   height: 10,
                                  // ),
                                  // Row(
                                  //   mainAxisAlignment:
                                  //       MainAxisAlignment.spaceEvenly,
                                  //   children: [
                                  //     ElevatedButton(
                                  //       onPressed: () {
                                  //         FocusScopeNode currentFocus =
                                  //             FocusScope.of(context);
                                  //         if (!currentFocus.hasPrimaryFocus) {
                                  //           currentFocus.unfocus();
                                  //         }
                                  //         // Navigator.of(context).push(
                                  //         //   MaterialPageRoute(
                                  //         //       builder: (context) =>
                                  //         //           CreateNewMealScreen()),
                                  //         // );
                                  //
                                  //         // addIngredients(context);
                                  //         // showBottomSheet();
                                  //       },
                                  //       child: Text(
                                  //         "Yes",
                                  //         style: TextStyle(fontSize: 18.0),
                                  //       ),
                                  //       style: ElevatedButton.styleFrom(
                                  //           // primary: HexColor(widget
                                  //           //     .mealsListData.startColor),
                                  //           ),
                                  //     ),
                                  //     ElevatedButton(
                                  //       onPressed: () {
                                  //         FocusScopeNode currentFocus =
                                  //             FocusScope.of(context);
                                  //         if (!currentFocus.hasPrimaryFocus) {
                                  //           currentFocus.unfocus();
                                  //         }
                                  //       },
                                  //       child: Text(
                                  //         "No",
                                  //         style: TextStyle(fontSize: 18.0),
                                  //       ),
                                  //       style: ElevatedButton.styleFrom(
                                  //           // primary: HexColor(widget
                                  //           //     .mealsListData.startColor),
                                  //           ),
                                  //     )
                                  //   ],
                                  // )
                                ],
                              ),
                            );
                    },
                  ),
                ),
                SizedBox(
                  height: 8,
                ),
              ],
            ),
            body: _isLoading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : nonAffiliatedConsultants.length == 0

                    ///because now we are showing every consultant in live call also
                    ///if not then uncomment this below two line
                    // ||
                    //         (_isNoConsultant == false && widget.liveCall == true)
                    ? Center(
                        // child: CircularProgressIndicator(),
                        child: Text(
                          'No Consultant available for ' +
                              widget.arg['specality_name'].toString().replaceAll('&amp;', '&'),
                          textAlign: TextAlign.center,
                        ),
                      )
                    // condition check for list empty
                    : Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Scrollbar(
                          child: ListView.builder(
                            addAutomaticKeepAlives: true,
                            itemCount: nonAffiliatedConsultants.length,
                            itemBuilder: (context, index) {
                              return nonAffiliatedConsultants.isEmpty
                                  ? Center(child: Text('No Consultant Available'))
                                  : Column(
                                      children: <Widget>[
                                        SizedBox(height: 3.0),
                                        createCard(nonAffiliatedConsultants[index])
                                      ],
                                    );
                            },
                          ),
                        ),
                      )),
      ),
    );
  }
}
