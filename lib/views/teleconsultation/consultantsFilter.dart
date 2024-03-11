import 'package:intl/intl.dart';

import '../../new_design/presentation/Widgets/dashboardWidgets/affiliation_widgets.dart';

class ConsFilter {
  static filterNonAffiliatedConsultants(arg, liveCall) async {
    var nonAffiliatedConsultants = [];
    bool sso = UpdatingColorsBasedOnAffiliations.ssoAffiliation != null &&
        UpdatingColorsBasedOnAffiliations.ssoAffiliation["affiliation_unique_name"] != null;
    var consultants = arg['consultant_list'];
    if (!sso) {
      for (int i = 0; i < consultants.length; i++) {
        // if (liveCall == false) {
        //   ///TODO 16T1: THIS 3 LINE FOR GETTING THE PROFILE PICTURE OF THE CONSULTANT WILL BE CALLED IN THE SELECTcONSULTANT FILE
        //   ///THINK SO...?
        //   // var imageValue =
        //   // await getConsultantImageURL(consultants[i]['ihl_consultant_id']);
        //   // consultants[i]['profile_picture'] = imageValue;
        // }
        if (consultants[i]['affilation_excusive_data'] == null ||
            consultants[i]['exclusive_only'] == false) {
          if (consultants[i]["ihl_consultant_id"] != "b82fd0384bba473086aaae70a7222a55" &&
              consultants[i]["ihl_consultant_id"] != 'b82fd0384bba473086aaae70a7222a17') {
            nonAffiliatedConsultants.add(consultants[i]);
          }
        }
        // else if(consultants[i]['affilation_excusive_data'] != null) {
        //   if(consultants[i]['affilation_excusive_data'].length == 0) {
        //     nonAffiliatedConsultants.add(consultants[i]);
        //   }
        // }
        else if (consultants[i]['affilation_excusive_data'] != null) {
          if (consultants[i]['affilation_excusive_data'].length != 0) {
            if (consultants[i]['affilation_excusive_data']['affilation_array'].length != 0 &&
                consultants[i]['exclusive_only'] == false) {
              nonAffiliatedConsultants.add(consultants[i]);
            }
          }
        }
        if (consultants[i]['affilation_excusive_data'] != null) {
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
    print(nonAffiliatedConsultants);
    return nonAffiliatedConsultants;
  }

  static filterConsultantsForAffiliation(arg, liveCall, companyName) async {
    var affConsultants = [];
    var flatConsultants = arg['consultant_list'];

    var affiliatedConsultants = [];

    for (int i = 0; i < flatConsultants.length; i++) {
      // if (liveCall == false) {
      //   var imageValue = await getConsultantImageURL(
      //       flatConsultants[i]['ihl_consultant_id']);
      //   flatConsultants[i]['profile_picture'] = imageValue;
      // }
      if (flatConsultants[i]['affilation_excusive_data'] != null) {
        if (flatConsultants[i]['affilation_excusive_data'].length != 0) {
          if (flatConsultants[i]['affilation_excusive_data']['affilation_array'].length != 0) {
            if (flatConsultants[i]["ihl_consultant_id"] != "b82fd0384bba473086aaae70a7222a55") {
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
        affiliationArray
            .add(affiliatedConsultants[i]['affilation_excusive_data']['affilation_array']);
        var affFlatConsultants = affiliationArray.expand((i) => i).toList();

        newList = affFlatConsultants
                ?.map((m) => m != null ? m['affilation_unique_name'] : "")
                ?.toList() ??
            [];

        newList1 =
            affFlatConsultants?.map((m) => m != null ? m['affilation_name'] : "")?.toList() ?? [];

        if (newList.contains(companyName) || newList1.contains(companyName)) {
          affConsultants.add(affiliatedConsultants[i]);
          // if (this.mounted) {
          //   setState(() {
          //     _isLoading = false;
          affiliationArray.clear();
          newList.clear();
          newList1.clear();
          //   });
          // }
        } else {
          affiliationArray.clear();
          // if (this.mounted) {
          //   setState(() {
          //     _isLoading = false;
          newList.clear();
          newList1.clear();
          //   });
          // }
        }
      }
    }

    print(affConsultants);
    return affConsultants;

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

  static filterNonAffiliatedCourses(arg) async {
    var nonAffiliatedCourses = [];
    var courses = arg['courses'];
    for (int i = 0; i < courses.length; i++) {
      if (courses[i]['affilation_excusive_data'] == null || courses[i]['exclusive_only'] == false) {
        nonAffiliatedCourses.add(courses[i]);
      }
      // else if(courses[i]['affilation_excusive_data'] != null) {
      //   if(courses[i]['affilation_excusive_data'].length == 0) {
      //     nonAffiliatedCourses.add(courses[i]);
      //   }
      // }
      else if (courses[i]['affilation_excusive_data'] != null) {
        if (courses[i]['affilation_excusive_data'].length != 0) {
          if (courses[i]['affilation_excusive_data']['affilation_array'].length == 0) {
            nonAffiliatedCourses.add(courses[i]);
          }
        }
      }
    }

    // return nonAffiliatedCourses ;
    var act = await apply_sorting(nonAffiliatedCourses);
    return act;
    // for(int i=0; i<courses.length; i++) {
    //   if(courses[i]['affilation_excusive_data'] == null) {
    //     nonAffiliatedCourses.add(courses[i]);
    //   }
    //   else if(courses[i]['affilation_excusive_data'].length == 0) {
    //     nonAffiliatedCourses.add(courses[i]);
    //   }
    //   else if(courses[i]['affilation_excusive_data']['affilation_array'].length == 0) {
    //     nonAffiliatedCourses.add(courses[i]);
    //   }
    // }
    //print(nonAffiliatedCourses);
  }

  // ignore: non_constant_identifier_names
  static apply_sorting(filter) {
    var activeClassAvailable = false;
    var currentDateTim = DateTime.now();
    for (int i = 0; i < filter.length; i++) {
      var courseDuration = filter[i]["course_duration"];
      String courseEndDuration = courseDuration.substring(13, 23);
      int lastIndexValue = filter[i]["course_time"].length - 1;
      String courseEndTimeFullValue =
          filter[i]["course_time"][lastIndexValue]; //02:00 PM - 07:00 PM
      String courseEndTime = courseEndTimeFullValue.substring(
          courseEndTimeFullValue.indexOf("-") + 1, courseEndTimeFullValue.length); //07:00 PM
      courseEndDuration = courseEndDuration + courseEndTime; //20-04-2022 07:00 PM
      DateTime endDat = DateFormat("dd-MM-yyyy").parse(courseEndDuration);
      if (endDat.isAfter(currentDateTim) ||
          (endDat.day == currentDateTim.day &&
              endDat.month == currentDateTim.month &&
              endDat.year == currentDateTim.year)) {
        activeClassAvailable = true;
        break;
      } else {
        activeClassAvailable = false;
      }
    }
    return activeClassAvailable;
  }

  static filterCoursesForAffiliation(arg, companyName) async {
    var affCourses = [];
    var flat = arg['courses'];

    var affiliatedCourses = [];

    for (int i = 0; i < flat.length; i++) {
      if (flat[i]['affilation_excusive_data'] != null) {
        if (flat[i]['affilation_excusive_data'].length != 0) {
          if (flat[i]['affilation_excusive_data']['affilation_array'].length != 0) {
            affiliatedCourses.add(flat[i]);
          }
        }
      }
    }

    List<dynamic> newList = [];
    List<dynamic> newList1 = [];

    if (affiliatedCourses.length != 0) {
      for (int i = 0; i < affiliatedCourses.length; i++) {
        var affiliationArray = [];
        affiliationArray.add(affiliatedCourses[i]['affilation_excusive_data']['affilation_array']);

        var affFlatCourses = affiliationArray.expand((i) => i).toList();

        newList =
            affFlatCourses?.map((m) => m != null ? m['affilation_unique_name'] : "")?.toList() ??
                [];

        newList1 =
            affFlatCourses?.map((m) => m != null ? m['affilation_name'] : "")?.toList() ?? [];

        if (newList.contains(companyName) || newList1.contains(companyName)) {
          affCourses.add(affiliatedCourses[i]);
          // if (this.mounted) {
          //   setState(() {
          affiliationArray.clear();
          newList.clear();
          newList1.clear();
          //   });
          // }
        } else {
          affiliationArray.clear();
          // if (this.mounted) {
          //   setState(() {
          newList.clear();
          newList1.clear();
          //   });
          // }
        }
      }
    }

    print(affCourses);
    var act = await apply_sorting(affCourses);
    return act;
  }
}
