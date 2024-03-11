import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:html/parser.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:strings/strings.dart';
import 'package:http/http.dart' as http;
import '../../../../../../constants/api.dart';
import '../../../../../../utils/app_colors.dart';
import '../../../../../../views/dietJournal/activity/activity_detail.dart';
import '../../../../../../views/dietJournal/models/get_todays_food_log_model.dart';
import '../../../../../../views/dietJournal/models/user_bookmarked_activity_model.dart';

import '../../../dashboard/common_screen_for_navigation.dart';

class ActivitySearchScreen extends StatefulWidget {
  final List<Activity> todayLogList;

  final DateTime selectedDate;
  ActivitySearchScreen({Key key, @required this.todayLogList,@required this.selectedDate}) : super(key: key);



  @override
  State<ActivitySearchScreen> createState() => _ActivitySearchScreen();
}

class _ActivitySearchScreen extends State<ActivitySearchScreen> {


  List<BookMarkedActivity> bookmarkedActivityList = [];
  List<String> bookmarkedActivityIdList = [];
  final TextEditingController _typeAheadController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  FocusNode typeAheadFocus =  FocusNode();
  bool showText = true;
  bool searchLoad = true;
  List<BookMarkedActivity> allActivitylist = [];
  List<Map<String, dynamic>> searchResults = [];
  final ScrollController _scrollController = ScrollController();
  bool novalues = false;
  int start = 20;
  String _query = '';
  TabController tabBarController;
  final ValueNotifier<int> _tabIndexNotifier = ValueNotifier<int>(0);
  int end = 20;
  final ValueNotifier<List<Map<String, dynamic>>> updatedSearchList = ValueNotifier([]);

//   // Debounced search method
//   void _onSearchTextChanged(String value) {
//     if (value.isNotEmpty) {
//       if (!submitShow || !searchLoad) {
//         setState(() {
//           submitShow = true;
//           searchLoad = true;
//         });
//       }
//
//       _debounce(() async {
//         List<Map<String, dynamic>> list =
//         await foodItemsService.getSuggestions(value, 1, 10);
//         _query = value;
//         searchResults = list;
//         updatedSearchList.value.clear();
//         updatedSearchList.value.addAll(searchResults);
//         setState(() {
//           searchLoad = false;
//         });
//       });
//     } else {
//       setState(() {
//         submitShow = false;
//       });
//     }
//   }
//
// // Debounce function
//   void _debounce(VoidCallback callback) {
//     const Duration debounceDuration = Duration(seconds: 2);
//     if (_debounceTimer != null) {
//       _debounceTimer.cancel();
//     }
//     _debounceTimer = Timer(debounceDuration, callback);
//   }

// Remember to define _debounceTimer as a class-level variable
//   Timer _debounceTimer;

  @override
  void initState() {
    super.initState();



    _scrollController.addListener(() async {
      // print(_scrollController.position.atEdge);
      if (_scrollController.position.atEdge) {
        if (!novalues) {
          start = end + 1;
          end = end + 20;
        }

        print(_query);
        print("$start to  $end");
        List<Map<String, dynamic>> ss = await ActivityItems.getSuggestions(_query, start, end);

        searchResults.addAll(ss);
        updatedSearchList.value = searchResults;
        updatedSearchList.notifyListeners();
        print('updated list' + updatedSearchList.value.length.toString());
        searchResults.toSet().toList();
        if (ss.length == 0) {
          novalues = true;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CommonScreenForNavigation(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () async {
            Get.back();
          }, //replaces the screen to Main dashboard
          color: Colors.white,
        ),
        title: Padding(padding: EdgeInsets.only(left: 15.w), child: const Text("Search Activity")),
        backgroundColor: HexColor('#6F72CA'),
      ),
      content: SizedBox(
        height: 100.h,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 15.0, right: 15.0, top: 5.h),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey,
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.search),
                            onPressed: () {},
                          ),
                          Expanded(
                            child: TextField(
                              onTap: () {},

                              onChanged: (String value) async {
                                if (mounted) {
                                  setState(() {
                                    // submitShow = true;
                                    searchLoad = true;
                                  });
                                }
                                List list = await ActivityItems.getSuggestions(value, 1, 20);
                                searchResults = list;
                                print('object====$list');
                                if (mounted) {
                                  setState(() {
                                    searchLoad = false;
                                  });
                                }
                              },
                              autofocus: true,
                              showCursor: true,
                              readOnly: false,
                              controller: _typeAheadController,
                              decoration: const InputDecoration(
                                hintText: 'Search Activity',
                                contentPadding:
                                EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                                border: InputBorder.none,
                              ),
                              // onSubmitted: (_) => _performSearch(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Visibility(
                      visible: true,
                      child: searchLoad &&
                          _typeAheadController.text != null &&
                          _typeAheadController.text != ""
                          ? Column(
                        children: [
                          Shimmer.fromColors(
                              direction: ShimmerDirection.ltr,
                              period: const Duration(seconds: 2),
                              baseColor: const Color.fromARGB(255, 240, 240, 240),
                              highlightColor: Colors.grey.withOpacity(0.2),
                              child: Container(
                                  margin: const EdgeInsets.all(8),
                                  width: 75.w,
                                  height: .5.h,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Text('Hello'))),
                        ],
                      )
                          : SingleChildScrollView(
                        child: _typeAheadController.text != "" &&
                            _typeAheadController.text != null &&
                            searchResults.isEmpty
                            ? Column(
                          children: const [
                            Text("No Result Found"),
                          ],
                        )
                            : SizedBox(
                          height: 65.h,
                          child: ListView.builder(
                              itemCount: searchResults.length,
                              itemBuilder: (BuildContext cntx, int index) {
                                return ListTile(
                                  title: Text(
                                    camelize(searchResults[index]['activity_name'] ??
                                        'Name Unknown'),
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.5),
                                  ),
                                  subtitle: Padding(
                                    padding:  EdgeInsets.all(8.sp),
                                    child: Text(
                                      searchResults[index]['activity_type'] == 'L'
                                          ? 'Light Impact'
                                          : searchResults[index]['activity_type'] == 'M'
                                          ? 'Medium Impact'
                                          : searchResults[index]['activity_type'] ==
                                          'V'
                                          ? 'High Impact'
                                          : 'Normal',
                                      style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.5),
                                    ),
                                  ),
                                  leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: Container(
                                        height: 50,
                                        width: 50,
                                        decoration: const BoxDecoration(
                                            borderRadius:
                                            BorderRadius.all(Radius.circular(20))),
                                        child: Image.network(
                                            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRFfwLJ_c9qyqUd7-Fa2V5mXqyc20VTWftelVPml48TJupo-TZKbBowiah2awK1s_0kPSQ&usqp=CAU')),
                                  ),
                                  onTap: () {
                                    Get.to(ActivityDetailScreen(
                                      allList: ActivityWidgets.selectedIndex.value
                                          .toString(),
                                      activityObj: searchResults[index],
                                      todayLogList: widget.todayLogList,
                                      selectedDate: widget.selectedDate,
                                    ));
                                  },
                                );
                              }),
                        ),

                        // SizedBox(
                        //   height: 15.h,
                        // )
                      ),
                    ),
                    Visibility(
                        visible: !searchLoad,
                        child: Container(
                          height: 60.h,
                        )),

                  ],
                ),
              ),
              // Container(
              //   height: 10.h,
              // )
            ],
          ),
        ),
      ),
    );
  }
}

class ActivityItems {
  static Future<List> getSuggestions(String query, int startIndex, int endPage) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    String iHLUserId = prefs.getString('ihlUserId');
    var food;

    var activity;

    List<Map<String, dynamic>> matches = [];
    http.Client _client = http.Client(); //3gb
    try {
      final http.Response response = await _client.get(
          Uri.parse('${API.iHLUrl}/consult/get_user_activity_search?activity_name=$query'),
          headers: {
            'Content-Type': 'application/json',
            'ApiToken': '${API.headerr['ApiToken']}',
            'Token': '${API.headerr['Token']}',
          });
      if (response.statusCode == 200) {
        String text = parseFragment(response.body).text;
        text = parseFragment(text).text; //needed to be done twise to avoid html tags


        activity = jsonDecode(text);
      }
      // print(food);
      for (int i = 0; i < activity.length; i++) {
        matches.add(activity[i]);
      }

      return matches;
    } catch (e) {
      return matches;
    }
  }
}

class ActivityWidgets {
  static ValueNotifier<int> selectedIndex = ValueNotifier(0);
}