import 'dart:convert';
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:connectanum/connectanum.dart';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ihl/constants/api.dart';
import 'package:ihl/constants/app_texts.dart';
import 'package:ihl/views/affiliation/selectConsultantCardForAffiliation.dart';
import 'package:ihl/widgets/ScrollessBasicPageUI.dart';
import 'package:ihl/widgets/offline_widget.dart';
import 'package:strings/strings.dart';

// ignore: must_be_immutable
class SelectConsultantForAffiliation extends StatefulWidget {
  String companyName;
  final bool liveCall;
  Map arg;

  SelectConsultantForAffiliation({this.arg, this.liveCall, this.companyName});

  @override
  _SelectConsultantForAffiliationState createState() =>
      _SelectConsultantForAffiliationState();
}

class _SelectConsultantForAffiliationState
    extends State<SelectConsultantForAffiliation> {
  http.Client _client = http.Client(); //3gb
  var affConsultants = [];

  List languageFilters = [];
  List consultantId = [];
  bool _isLoading = false;
  bool _isNoConsultant = false;
  var docStatus;
  Session session1;

  @override
  void initState() {
    super.initState();
    // affConsultants = widget.arg["consultant_list"];results = widget.arg['consultant_list'];

    filterConsultantsForAffiliation();
    _isLoading = true;
    if (widget.liveCall == true) {
      onlineFilter();
    }
  }

  Future<String> getConsultantImageURL(
    var map,
  ) async {
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
        var consultantIDAndImage = map[1] == 'GENIX'
            ? imageOutput["genixbase64list"]
            : imageOutput["ihlbase64list"];
        for (var i = 0; i < consultantIDAndImage.length; i++) {
          if (map[0] == consultantIDAndImage[i]['consultant_ihl_id']) {
            var base64Image = consultantIDAndImage[i]['base_64'].toString();
            base64Image = base64Image.replaceAll('data:image/jpeg;base64,', '');
            base64Image = base64Image.replaceAll('}', '');
            base64Image = base64Image.replaceAll('data:image/jpegbase64,', '');
            var image;
            var consultantImage;
            if (this.mounted) {
              setState(() {
                consultantImage = base64Image;
              });
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
      } else {
        return AvatarImage.defaultUrl;
        print(response.body);
      }
    } catch (e) {
      print(e.toString());
      return AvatarImage.defaultUrl;
    }
  }

  filterConsultantsForAffiliation() async {
    var flatConsultants = widget.arg['consultant_list'];

    var affiliatedConsultants = [];

    for (int i = 0; i < flatConsultants.length; i++) {
      if (widget.liveCall == false) {
        var imageValue = await getConsultantImageURL(
            flatConsultants[i]['vendor_id'] == "GENIX"
                ? [
                    flatConsultants[i]['vendor_consultant_id'],
                    flatConsultants[i]['vendor_id']
                  ]
                : [
                    flatConsultants[i]['ihl_consultant_id'],
                    flatConsultants[i]['vendor_id']
                  ]);
        // flatConsultants[i]['ihl_consultant_id']);
        flatConsultants[i]['profile_picture'] = imageValue;
      }
      if (flatConsultants[i]['affilation_excusive_data'] != null) {
        if (flatConsultants[i]['affilation_excusive_data'].length != 0) {
          if (flatConsultants[i]['affilation_excusive_data']['affilation_array']
                  .length !=
              0) {
            if (flatConsultants[i]["ihl_consultant_id"] !=
                "b82fd0384bba473086aaae70a7222a55") {
              affiliatedConsultants.add(flatConsultants[i]);
            }
          }
        }
      }
    }

    var affiliationArray = [];

    List<dynamic> newList = [];
    List<dynamic> newList1 = [];

    if (affiliatedConsultants.length != 0) {
      for (int i = 0; i < affiliatedConsultants.length; i++) {
        affiliationArray.add(affiliatedConsultants[i]
            ['affilation_excusive_data']['affilation_array']);
        var affFlatConsultants = affiliationArray.expand((i) => i).toList();

        newList = affFlatConsultants
                ?.map((m) => m != null ? m['affilation_unique_name'] : "")
                ?.toList() ??
            [];

        newList1 = affFlatConsultants
                ?.map((m) => m != null ? m['affilation_name'] : "")
                ?.toList() ??
            [];

        if (newList.contains(widget.companyName) ||
            newList1.contains(widget.companyName)) {
          affConsultants.add(affiliatedConsultants[i]);
          affConsultants
              .removeWhere((element) => element['provider'] == 'APOLLO');
          if (this.mounted) {
            setState(() {
              //_isLoading = false;
              affiliationArray.clear();
              newList.clear();
              newList1.clear();
            });
          }
        } else {
          affiliationArray.clear();
          if (this.mounted) {
            setState(() {
              //_isLoading = false;
              newList.clear();
              newList1.clear();
            });
          }
        }
      }
    }
    onlineFilter();
    print(affConsultants);

    /*
    var consultants = widget.arg['consultant_list'];
    var affiliatedConsultants = [];
    List<List<dynamic>> affiliationArrayMap = [];
    var affiliationArray = [];

    // for(int i=0; i<consultants.length; i++) {
    //   if(consultants[i]['affilation_excusive_data'] != null) {
    //     affiliatedConsultants.add(consultants[i]);
    //   }
    //   else if(consultants[i]['affilation_excusive_data'] != null) {
    //     if(consultants[i]['affilation_excusive_data'].length != 0) {
    //       affiliatedConsultants.add(consultants[i]);
    //     }
    //   }
    //   else if(consultants[i]['affilation_excusive_data'] != null) {
    //     if(consultants[i]['affilation_excusive_data'].length != 0) {
    //       if(consultants[i]['affilation_excusive_data']['affilation_array'].length != 0) {
    //         affiliatedConsultants.add(consultants[i]);
    //       }
    //     }
    //   }
    // }

    for (int i = 0; i < consultants.length; i++) {
      if (consultants[i]['affilation_excusive_data'] != null) {
        if (consultants[i]['affilation_excusive_data'].length != 0) {
          if (consultants[i]['affilation_excusive_data']['affilation_array']
                  .length !=
              0) {
            affiliatedConsultants.add(consultants[i]);
          }
        }
      }
    }

    if (affiliatedConsultants.length != 0) {
      for (int i = 0; i < affiliatedConsultants.length; i++) {
        affiliationArray.add(affiliatedConsultants[i]
            ['affilation_excusive_data']['affilation_array']);
        affiliationArrayMap.add(affiliationArray[i]);
      }

      var affiliationMap = affiliationArrayMap.asMap();

      for (var i = 0; i < affiliatedConsultants.length; i++) {
        if (affiliationMap[i].isNotEmpty &&
            affiliationMap[i][0]['affilation_unique_name'] ==
                widget.companyName) {
          affConsultants.add(affiliatedConsultants[i]);
        }
      }
    }
    print(affConsultants);

     */
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
    List filteredResults = [];
    for (int i = 0; i <= affConsultants.length - 1; i++) {
      docStatus = await httpStatus(affConsultants[i]['ihl_consultant_id']);
      var imageValue = await getConsultantImageURL(
          affConsultants[i]['vendor_id'] == "GENIX"
              ? [
                  affConsultants[i]['vendor_consultant_id'],
                  affConsultants[i]['vendor_id']
                ]
              : [
                  affConsultants[i]['ihl_consultant_id'],
                  affConsultants[i]['vendor_id']
                ]);
      affConsultants[i]['profile_picture'] = imageValue;
      if (docStatus == 'Online' ||
          docStatus == 'online' ||
          docStatus == 'M' ||
          docStatus == 'F') {
        // Uncomment this commented func if need of online consultant on top and offline consultant next to that in same list
        filteredResults.insert(0, affConsultants[i]);
        //filteredResults.add(affConsultants[i]);
        _isNoConsultant = true;
      } else {
        // Uncomment this commented func if need of online consultant on top and offline consultant next to that in same list
        // filteredResults.add(results[i]);
        filteredResults.add(affConsultants[i]);
      }
    }
    if (this.mounted) {
      Future.delayed(const Duration(seconds: 5), () {
        setState(() {
          affConsultants = filteredResults;
          //affConsultants.length != 0 ??
          //    affConsultants.sort((a, b) => a["name"].compareTo(b["name"]));
          _isLoading = false;
        });
      });
    }
  }

  Future<String> httpStatus(var consultantId) async {
    var status;
    final response = await _client.post(
      Uri.parse(API.iHLUrl + '/consult/getConsultantLiveStatus'),
      headers: {
        'Content-Type': 'application/json',
        'ApiToken': '${API.headerr['ApiToken']}',
        'Token': '${API.headerr['Token']}',
      },
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
      print('response failure');
    }

    return status;
  }

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
      for (int i = 0; i < affConsultants.length; i++) {
        if (affConsultants[i]['languages_Spoken'].contains(k)) {
          filtered.add(affConsultants[i]);
        }
      }
    }
    if (this.mounted) {
      setState(() {
        affConsultants = filtered;
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

  Widget createCard(Map mp, int index) {
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
    mp['livecall'] = widget.arg['livecall'];
    return SelectConsultantCardForAffiliation(
      index,
      widget.companyName,
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

  @override
  Widget build(BuildContext context) {
    return ConnectivityWidgetWrapper(
      disableInteraction: true,
      offlineWidget: OfflineWidget(),
      child: ScrollessBasicPageUI(
          appBar: Column(
            children: [
              SizedBox(
                width: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    color: Colors.white,
                  ),
                  Flexible(
                    child: AutoSizeText(
                      AppTexts.selectConsultant,
                      // overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      maxFontSize: 25,
                      minFontSize: 18,
                      style: TextStyle(color: Colors.white, fontSize: 25),
                    ),
                  ),
                  SizedBox(
                    width: 40,
                  )
                ],
              ),
              Text(
                widget.arg['specality_name'].toString(),
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 25),
              ),
            ],
          ),
          body: _isLoading
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : affConsultants.length == 0

                  ///because now we are showing every consultant in live call also
                  ///if not then uncomment this below two line
                  // ||
                  //         (_isNoConsultant == false && widget.liveCall == true)
                  ? Center(
                      child: CircularProgressIndicator(),
                      // child: Text(
                      //   'No Consultant available for ' +
                      //       widget.arg['specality_name'].toString(),
                      //   textAlign: TextAlign.center,
                      // ),
                    )
                  // condition check for list empty
                  : Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Scrollbar(
                        child: ListView.builder(
                          addAutomaticKeepAlives: true,
                          itemCount: affConsultants.length,
                          itemBuilder: (context, index) {
                            return affConsultants.isEmpty
                                ? Center(child: Text('No Consultant Available'))
                                : Column(
                                    children: <Widget>[
                                      SizedBox(height: 3.0),
                                      createCard(affConsultants[index], index)
                                    ],
                                  );
                          },
                        ),
                      ),
                    )),
    );
  }
}
