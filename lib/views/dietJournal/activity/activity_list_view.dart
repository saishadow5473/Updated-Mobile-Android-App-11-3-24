import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/views/dietJournal/DietJournalScrollessBasicPageUI.dart';
import 'package:ihl/views/dietJournal/activity/activity_detail.dart';
import 'package:ihl/views/dietJournal/activity/all_activity_list_tab.dart';
import 'package:ihl/views/dietJournal/activity/bookmark_activity_list_tab.dart';
import 'package:ihl/views/dietJournal/activity/recents_list_tab.dart';
import 'package:ihl/views/dietJournal/models/user_bookmarked_activity_model.dart';
import 'package:ihl/views/dietJournal/title_widget.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:strings/strings.dart';

import '../../../constants/api.dart';
import '../apis/list_apis.dart';
import '../models/get_todays_food_log_model.dart';

class ActivityListScreen extends StatefulWidget {
  final List<Activity> todayLogList;

  final DateTime selectedDate;
  ActivityListScreen({Key key, @required this.todayLogList, @required this.selectedDate})
      : super(key: key);
  @override
  _ActivityListScreenState createState() => _ActivityListScreenState();
}

class _ActivityListScreenState extends State<ActivityListScreen>
    with SingleTickerProviderStateMixin {
  // List<BookMarkedActivity> activityList = [];
  List<BookMarkedActivity> bookmarkedActivityList = [];
  List<String> bookmarkedActivityIdList = [];
  final TextEditingController _typeAheadController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  FocusNode typeAheadFocus = FocusNode();
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
  @override
  void initState() {
    super.initState();
    ActivityWidgets.selectedIndex.value = 0;
    tabBarController = TabController(
      vsync: this,
      length: 3,
      initialIndex: 0,
    );
    tabBarController.addListener(() {
      ActivityWidgets.selectedIndex.value = tabBarController.index;
      _tabIndexNotifier.value = ActivityWidgets.selectedIndex.value;
    });
    getAllActivityList();
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
        print('updated list${updatedSearchList.value.length}');
        searchResults.toSet().toList();
        if (ss.length == 0) {
          novalues = true;
        }
      }
    });
  }

  void getAllActivityList() async {
    List<BookMarkedActivity> details = await ListApis.getActivityList();

    for (int i = 0; i < details.length; i++) {
      bool exists =
          allActivitylist.any((BookMarkedActivity fav) => fav.activityId == details[i].activityId);
      if (!exists) {
        allActivitylist.add(details[i]);
        // print(allActivitylist);
      }
    }
    if (allActivitylist.isNotEmpty) {
      setState(() {
        //loaded = true;
      });
    } else {
      setState(() {
        //loaded = true;
        //empty = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DietJournalScrollessBasicPageUI(
      topColor: HexColor('#6F72CA'),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: Colors.white,
          ),
        ),
        title: const AutoSizeText(
          'Log Activity',
          style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w500, color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: DefaultTabController(
        length: 3,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              const SizedBox(
                height: 20,
              ),
              const FoodTitleView(
                titleTxt: 'Choose your Activity',
                subTxt: '',
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                  margin: const EdgeInsets.only(top: 20, left: 20, right: 20),
                  alignment: Alignment.topLeft,
                  child: Form(
                      key: _formKey,
                      child: Theme(
                        data: ThemeData(
                          primaryColor: Colors.indigo,
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
                      ))),
              const SizedBox(
                height: 20,
              ),
              Align(
                alignment: Alignment.topLeft,
                child: Container(
                  margin: const EdgeInsets.only(left: 20, right: 20),
                  height: 50,
                  child: PreferredSize(
                      preferredSize: const Size.fromHeight(kToolbarHeight),
                      child: ValueListenableBuilder(
                          valueListenable: _tabIndexNotifier,
                          builder: (BuildContext context, int tabIndex, Widget child) {
                            return SizedBox(
                              height: 16.w,
                              width: 100.w,
                              child: TabBar(
                                controller: tabBarController,
                                tabs: [
                                  TabWidget(title: 'All'),
                                  TabWidget(title: 'Recent'),
                                  // Tab(text: 'Bookmarks'),
                                  TabWidget(title: 'Favourite'),
                                ],
                                indicatorColor: Colors.transparent,
                                indicatorWeight: 4,
                                labelPadding: EdgeInsets.symmetric(horizontal: 1.w),
                                isScrollable: true,
                                indicatorPadding: EdgeInsets.zero,
                              ),
                            );
                          })),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: TabBarView(
                  physics: const NeverScrollableScrollPhysics(),
                  controller: tabBarController,
                  children: [
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
                                              subtitle: Text(
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
                    RecentsActivityTab(todayLogList: widget.todayLogList),
                    BookmarkActivityTab(todayLogList: widget.todayLogList),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget TabWidget({String title}) {
    List keys = ["All", "Recent", "Favourite"];
    return Material(
      color: Colors.transparent,
      borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(0),
          bottomRight: Radius.circular(25),
          topLeft: Radius.circular(25),
          topRight: Radius.circular(0)),
      // elevation: keys[0] == title ? 0 : 3,
      child: ClipPath(
          clipper: const ShapeBorderClipper(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(0),
                      bottomRight: Radius.circular(25),
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(0)))),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 10.w,
            width: 30.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: const Color(0XFFDCDBDB),
                border: keys[ActivityWidgets.selectedIndex.value] != title
                    ? null
                    : Border(bottom: BorderSide(color: AppColors.primaryColor, width: 1.w))),
            child: Text(title),
          )),
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
