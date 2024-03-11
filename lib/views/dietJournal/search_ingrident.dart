import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ihl/constants/api.dart';
import 'package:ihl/new_design/data/providers/network/networks.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/views/dietJournal/DietJournalUI.dart';
import 'package:ihl/views/dietJournal/create_new_ingrident.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchIngridientScreen extends StatefulWidget {
  const SearchIngridientScreen();
  @override
  _SearchIngridientScreenState createState() => _SearchIngridientScreenState();
}

class _SearchIngridientScreenState extends State<SearchIngridientScreen> {
  bool submitted = false;
  final TextEditingController _typeAheadController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  FocusNode typeAheadFocus = new FocusNode();
  ScrollController _scrollController = new ScrollController();
  int start = 20;
  int end = 20;
  String _query = '';
  final ValueNotifier<List<Map<String, dynamic>>> updatedSearchList = ValueNotifier([]);
  bool novalues = false;
  @override
  void initState() {
    super.initState();
    getDetails();
    _scrollController.addListener(() async {
      // print(_scrollController.position.atEdge);
      if (_scrollController.position.atEdge) {
        if (!novalues) {
          start = end + 1;
          end = end + 20;
        }

        print(_query);
        print(start.toString() + " to  " + end.toString());
        List<Map<String, dynamic>> ss = await IngridientItems.getSuggestions(_query, start, end);
        log('temp list' + ss.length.toString() + " main list" + searchResults.length.toString());
        searchResults.addAll(ss);
        updatedSearchList.value = searchResults;
        updatedSearchList.notifyListeners();
        print('updated list' + updatedSearchList.value.length.toString());
        searchResults.toSet().toList();

        if (ss.length == 0) {
          novalues = true;
        }
        log("end reached +${searchResults.length}");
      }
    });
  }

  void getDetails() async {}

  Widget _customButton() {
    return Container(
      height: 60,
      child: IgnorePointer(
        ignoring: submitted,
        child: GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: Color(0xFF19a9e5),
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Center(
                  child: submitted
                      ? CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : Text(
                          'Submit',
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
      ),
    );
  }

  // ScrollController _scrollController;
  List<Map<String, dynamic>> searchResults = [];
  bool isLoading = true;
  bool reponseListEmpty = false;
  @override
  Widget build(BuildContext context) {
    // final paginationOptions = PaginationOptions(
    //   pageSize: 20,
    //   maxPages: 5,
    //   autoPaginate: true,
    // );

    return DietJournalUI(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Search Ingredients',
          style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w500, color: Colors.white),
          // style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
          maxLines: 1,
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);

          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: Form(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 30.0,
                ),
                Container(
                  decoration: BoxDecoration(
                    color: FitnessAppTheme.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8.0),
                        bottomLeft: Radius.circular(8.0),
                        bottomRight: Radius.circular(8.0),
                        topRight: Radius.circular(8.0)),
                    border: Border.all(width: 0.4, color: FitnessAppTheme.grey.withOpacity(0.3)),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                          color: FitnessAppTheme.grey.withOpacity(0.2),
                          offset: Offset(1.1, 1.1),
                          blurRadius: 10.0),
                    ],
                  ),
                  margin: const EdgeInsets.all(8.0),
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20),
                      Text(
                        ' Search Ingredients to add',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontFamily: FitnessAppTheme.fontName,
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          letterSpacing: 0.5,
                          color: AppColors.textitemTitleColor,
                        ),
                      ),
                      SizedBox(height: 10),
                      Autocomplete<Map<String, dynamic>>(
                        optionsMaxHeight: 0,
                        optionsBuilder: (TextEditingValue _typeAheadController) {
                          if (_typeAheadController.text.isEmpty) {
                            return const Iterable<Map<String, dynamic>>.empty();
                          }

                          return updatedSearchList.value.where((Map<String, dynamic> option) {
                            final String name = option['ingredient'].toString().toLowerCase();
                            return name.contains(_typeAheadController.text.toLowerCase());
                          });
                        },
                        // onSelected: (Map<String, dynamic> selection) {},
                        fieldViewBuilder: (BuildContext context,
                            TextEditingController _typeAheadController,
                            FocusNode focusNode,
                            VoidCallback onFieldSubmitted) {
                          return TextField(
                            controller: _typeAheadController,
                            focusNode: focusNode,
                            decoration: InputDecoration(
                              labelStyle: typeAheadFocus.hasPrimaryFocus
                                  ? TextStyle(
                                      color: AppColors.dietJournalOrange,
                                    )
                                  : TextStyle(),
                              border: new OutlineInputBorder(
                                  borderRadius:
                                      const BorderRadius.all(const Radius.circular(20.0))),
                              labelText: 'Search Ingredient',
                              prefixIcon: Padding(
                                padding: const EdgeInsetsDirectional.only(end: 8.0),
                                child: Icon(Icons.search),
                              ),
                            ),
                            onChanged: (value) async {
                              setState(() {
                                isLoading = false;
                              });
                              List<Map<String, dynamic>> list =
                                  await IngridientItems.getSuggestions(value, 1, 20);
                              _query = value;
                              searchResults = list;
                              _typeAheadController.notifyListeners();
                              updatedSearchList.value.clear();
                              updatedSearchList.value.addAll(searchResults);
                              if (list.isNotEmpty) {
                                setState(() {
                                  isLoading = true;
                                  reponseListEmpty = false;
                                });
                              }
                              if (list.isEmpty) {
                                setState(() {
                                  isLoading = false;
                                  reponseListEmpty = true;
                                });
                              }
                              if (_query == '') {
                                setState(() {
                                  isLoading = true;
                                  reponseListEmpty = false;
                                });
                              }
                            },
                            onSubmitted: (value) {
                              // onFieldSubmitted();
                            },
                          );
                        },
                        // displayStringForOption: (Map<String, dynamic> option) =>
                        //     option['ingredient'].toString(),
                        optionsViewBuilder: (context, onSelected, options) {
                          print(options);
                          return ValueListenableBuilder(
                              valueListenable: updatedSearchList,
                              builder: (context, value, _) {
                                return Material(
                                  child: isLoading
                                      ? Padding(
                                          padding: EdgeInsets.only(
                                              top: 0, bottom: 20.sp, left: 10.sp, right: 10.sp),
                                          // child: SingleChildScrollView(
                                          //   controller: _scrollController,
                                          //   scrollDirection: Axis.vertical,
                                          //   child: Column(
                                          //       crossAxisAlignment: CrossAxisAlignment.start,
                                          //       children: options.map((e) {
                                          //         return Container(
                                          //           padding: EdgeInsets.only(
                                          //               left: 10.sp, right: 10.sp, top: 10.sp, bottom: 15.sp),
                                          //           child: Column(
                                          //             crossAxisAlignment: CrossAxisAlignment.start,
                                          //             children: [
                                          //               Text(e['ingredient']),
                                          //               Text(e['calories'] + ' Kcal')
                                          //             ],
                                          //           ),
                                          //         );
                                          //       }).toList()),
                                          // ),
                                          child: ListView.builder(
                                            padding: EdgeInsets.all(0.0),
                                            controller: _scrollController,
                                            scrollDirection: Axis.vertical,
                                            shrinkWrap: true,
                                            itemCount: value.length,
                                            itemBuilder: (BuildContext context, int index) {
                                              final Map<String, dynamic> option =
                                                  value.elementAt(index);
                                              return isLoading
                                                  ? ListTile(
                                                      title: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment.start,
                                                        children: [
                                                          Text(option['ingredient']),
                                                          Text(option['calories'] + ' Cal')
                                                        ],
                                                      ),
                                                      onTap: () async {
                                                        await IngridientItems.getIngredientDetails(
                                                            option['food_item_id'] ??
                                                                option["food_id"],
                                                            context);
                                                      },
                                                    )
                                                  : Center(
                                                      child: CircularProgressIndicator(),
                                                    );
                                            },
                                          ),
                                        )
                                      : Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                );
                              });
                        },
                      ),
                      SizedBox(height: 40),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                if (!isLoading)
                  Container(
                    child: reponseListEmpty
                        ? Container(
                            child: Column(
                              children: [
                                Text(
                                  'Add New Ingredient ?',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: AppColors.appTextColor, fontSize: 18.0),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        FocusScopeNode currentFocus = FocusScope.of(context);
                                        if (!currentFocus.hasPrimaryFocus) {
                                          currentFocus.unfocus();
                                        }
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) => CreateNewIngridientScreen()),
                                        );
                                        // addIngredients(context);
                                        // showBottomSheet();
                                      },
                                      child: Text(
                                        "Yes",
                                        style: TextStyle(fontSize: 18.0),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.dietJournalOrange,
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        FocusScopeNode currentFocus = FocusScope.of(context);
                                        if (!currentFocus.hasPrimaryFocus) {
                                          currentFocus.unfocus();
                                        }
                                      },
                                      child: Text(
                                        "No",
                                        style: TextStyle(fontSize: 18.0),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.dietJournalOrange,
                                      ),
                                    )
                                  ],
                                )
                              ],
                            ),
                          )
                        : Center(
                            child: CircularProgressIndicator(),
                          ),
                  ),
                SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class IngridientItems {
  static Future<List> getSuggestions(String query, int startIndex, int endIndex) async {
    var food = [];

    final prefs = await SharedPreferences.getInstance();
    String iHLUserId = prefs.getString('ihlUserId');
    List<Map<String, dynamic>> matches = [];
    http.Client _client = http.Client(); //3gb

    final response = await dio.post(API.iHLUrl + '/foodjournal/list_of_ingredient_starts_with',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'ApiToken': '${API.headerr['ApiToken']}',
            'Token': '${API.headerr['Token']}',
          },
        ),
        data: jsonEncode(<String, dynamic>{
          "search_string": query,
          "ihl_user_id": iHLUserId,
          "advanceSearch": "true",
          "start_index": startIndex, // mandatory
          "end_index": endIndex // mandatory
        }));
    if (response.statusCode == 200) {
      food = response.data["final_food_list"];
    }

    if (food != null) {
      for (int i = 0; i < food.length; i++) {
        matches.add(food[i]);
      }
    }
    print(matches);
    return matches;
  }

  static void getIngredientDetails(String ingredientId, BuildContext cont) async {
    Map<String, dynamic> foodDetail;

    final prefs = await SharedPreferences.getInstance();
    String iHLUserId = prefs.getString('ihlUserId');
    http.Client _client = http.Client();
    //3gb

    final response =
        await _client.post(Uri.parse(API.iHLUrl + '/foodjournal/view_all_ingredient_detail'),
            headers: {
              'Content-Type': 'application/json',
              'ApiToken': '${API.headerr['ApiToken']}',
              'Token': '${API.headerr['Token']}',
            },
            body: json.encode(
              {"food_id": ingredientId},
            ));
    // final response = await _client.get(
    //   Uri.parse(API.iHLUrl +
    //       '/consult/get_ingredient_details?ingredient_item_id=' +
    //       ingredientId +
    //       '&ihl_user_id=$iHLUserId'),
    //   headers: {
    //     'Content-Type': 'application/json',
    //     'ApiToken': '${API.headerr['ApiToken']}',
    //     'Token': '${API.headerr['Token']}',
    //   },
    // );
    if (response.statusCode == 200) {
      var food = jsonDecode(response.body.replaceAll("&quot;", ""));
      foodDetail = food['message'][0];
    }
    Navigator.of(cont).pop(foodDetail);
  }
}
