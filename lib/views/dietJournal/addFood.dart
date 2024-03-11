import 'dart:convert';

import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:giff_dialog/giff_dialog.dart';
import 'package:http/http.dart' as http;
import 'package:ihl/constants/api.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/views/dietJournal/DietJournalUI.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:strings/strings.dart';

class AddFood extends StatefulWidget {
  final String mealType;
  const AddFood({Key key, this.mealType}) : super(key: key);

  @override
  _AddFoodState createState() => _AddFoodState();
}

class _AddFoodState extends State<AddFood> {
  final TextEditingController _typeAheadController = TextEditingController();

  bool selected = false;
  ExpandableController _expandableController;
  bool expanded = true;

  List<String> ingredientsImages = [
    "https://images.unsplash.com/photo-1563865436874-9aef32095fad?ixid=MnwxMjA3fDB8MHxzZWFyY2h8Mnx8aW5ncmVkaWVudHN8ZW58MHx8MHx8&ixlib=rb-1.2.1&w=1000&q=80",
    "https://www.bakingbusiness.com/ext/resources/2019/1/01142019/Ingredients2019.jpg?1547588432",
    "https://cdn-a.william-reed.com/var/wrbm_gb_food_pharma/storage/images/publications/food-beverage-nutrition/foodnavigator.com/news/market-trends/meat-free-convenience-and-traceability-ehl-ingredients-reveals-2020-food-trends/10511260-1-eng-GB/Meat-free-convenience-and-traceability-EHL-Ingredients-reveals-2020-food-trends_wrbm_large.jpg",
    "https://img.freepik.com/free-photo/flat-lay-asian-food-ingredients-mix-with-copy-space_23-2148377555.jpg?size=626&ext=jpg",
    "https://www.foodingredientfacts.org/wp-content/uploads/2016/02/AdobeStock_87648286-300x200.jpeg",
    "https://img1.10bestmedia.com/Images/Photos/384075/GettyImages-1221418765_54_990x660.jpg",
    "https://www.bakingbusiness.com/ext/resources/TopicLandingPages/Ingredients-and-Formulating.jpg?1526062895",
    "https://images.pexels.com/photos/256318/pexels-photo-256318.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500",
    "https://image.freepik.com/free-photo/close-up-cooking-herbs-bowl_23-2148285422.jpg",
    "https://img.freepik.com/free-vector/winter-square-design-with-spices-herbs_124848-212.jpg?size=338&ext=jpg",
    "https://d2gg9evh47fn9z.cloudfront.net/800px_COLOURBOX23915861.jpg",
    "https://food.unl.edu/newsletters/images/basic-ingredients-for-baking.png"
  ];

  List<String> ingredients = [
    "Salt",
    "Pepper",
    "Oil",
    "Onion",
    "Flour",
    "Spice",
    "Sugar",
    "Egg",
    "Lemon",
    "Butter",
    "Cheese",
    "Pulses"
  ];

  @override
  void initState() {
    super.initState();
    _expandableController = ExpandableController(
      initialExpanded: false,
    );
    _expandableController.addListener(() {
      if (this.mounted) {
        setState(() {
          expanded = _expandableController.expanded;
        });
      }
    });
  }

  var food = [];
  List<String> matches = <String>[];
  http.Client _client = http.Client(); //3gb

  getFromAPI(String foodItem) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var data = prefs.get('data');
    Map res = jsonDecode(data);
    var ihlUserID = res['User']['id'];
    final response = await _client.get(
        Uri.parse(API.iHLUrl +
            '/foodjournal/list_of_food_items_starts_with?search_string=' +
            foodItem +
            '&ihl_user_id=' +
            ihlUserID +
            '&is_advance_search=true'),
        headers: {
          'Content-Type': 'application/json',
          'ApiToken': '${API.headerr['ApiToken']}',
          'Token': '${API.headerr['Token']}',
        });
    if (response.statusCode == 200) {
      food = jsonDecode(response.body);
    }

    print(food);
    for (int i = 0; i < food.length; i++) {
      if (this.mounted) {
        setState(() {
          matches.add(food[i]['item_name'].toString());
        });
      }
    }
    print(matches);
    matches.retainWhere((s) => s.toLowerCase().contains(foodItem.toLowerCase()));
  }

  List<String> getSuggestions(String query) {
    getFromAPI(query);
    return matches;
  }

  @override
  Widget build(BuildContext context) {
    return DietJournalUI(
      backgroundColor: AppColors.cardColor,
      appBar: Column(
        children: [
          SizedBox(
            width: 30,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back_ios),
                onPressed: () {},
                color: Colors.white,
                tooltip: 'Back',
              ),
              Flexible(
                child: Center(
                  child: Text(
                    widget.mealType ?? "Add Meal",
                    style:
                        TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              SizedBox(
                width: 40,
              ),
            ],
          ),
          SizedBox(
            height: 10.0,
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0, bottom: 10.0),
              child: Column(
                children: <Widget>[
                  Container(
                    decoration: new BoxDecoration(
                      color: Colors.white,
                      borderRadius: new BorderRadius.all(
                        new Radius.circular(20.0),
                      ),
                    ),
                    child: TypeAheadFormField(
                      textFieldConfiguration: TextFieldConfiguration(
                          controller: this._typeAheadController,
                          decoration: InputDecoration(
                              fillColor: Colors.white,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: const BorderRadius.all(const Radius.circular(20.0)),
                                borderSide: BorderSide(color: AppColors.dietJournalOrange),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: const BorderRadius.all(const Radius.circular(20.0)),
                                borderSide: BorderSide(color: AppColors.dietJournalOrange),
                              ),
                              border: new OutlineInputBorder(
                                  borderRadius:
                                      const BorderRadius.all(const Radius.circular(20.0))),
                              labelText: "Search " + widget.mealType,
                              labelStyle: TextStyle(color: AppColors.dietJournalOrange))),
                      suggestionsCallback: (pattern) {
                        return Food().getSuggestions(pattern);
                        // FoodItems().getFromAPI(_typeAheadController.text);
                        // return getSuggestions(pattern);
                      },
                      suggestionsBoxDecoration: SuggestionsBoxDecoration(
                          color: Colors.white,
                          elevation: 2.0,
                          borderRadius: BorderRadius.circular(10.0)),
                      itemBuilder: (context, suggestion) {
                        return ListTile(
                          title: Text(suggestion),
                        );
                      },
                      transitionBuilder: (context, suggestionsBox, controller) {
                        return suggestionsBox;
                      },
                      onSuggestionSelected: (suggestion) {
                        this._typeAheadController.text = suggestion;
                        if (this.mounted) {
                          setState(() {
                            selected = true;
                          });
                        }
                      },
                      noItemsFoundBuilder: (value) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Column(
                            children: [
                              Text(
                                'No Food item Found!',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: AppColors.appTextColor, fontSize: 18.0),
                              ),
                              Text(
                                'Would you like to add it?',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: AppColors.appTextColor, fontSize: 18.0),
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
                                    },
                                    child: Text(
                                      "Yes",
                                      style: TextStyle(fontSize: 18.0),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      primary: AppColors.dietJournalOrange,
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
                                      primary: AppColors.dietJournalOrange,
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                        );
                      },
                      // onSaved: (value) => this._selectedCity = value,
                    ),
                  ),
                ],
              ),
            ),
            Visibility(
              visible: selected ? true : false,
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0, top: 0.0),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.topRight,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(top: 30.0),
                          child: Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(20.0),
                                    bottomLeft: Radius.circular(20.0),
                                    bottomRight: Radius.circular(20.0),
                                    topRight: Radius.circular(20.0))),
                            color: Colors.white,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // SizedBox(height: 130.0,),
                                Padding(
                                  padding: const EdgeInsets.only(left: 15.0, top: 20.0),
                                  child: Row(
                                    children: [
                                      Text(
                                        camelize(_typeAheadController.text),
                                        style:
                                            TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(
                                        width: 20.0,
                                      ),
                                      Container(
                                        width: 40.0,
                                        height: 40.0,
                                        child: RawMaterialButton(
                                          key: Key('addToFav'),
                                          onPressed: () {
                                            showDialog(
                                                context: context,
                                                builder: (_) => NetworkGiffDialog(
                                                      onlyOkButton: true,
                                                      entryAnimation: EntryAnimation.bottom,
                                                      cornerRadius: 10.0,
                                                      buttonOkColor: AppColors.dietJournalOrange,
                                                      title: Text('Add to Favourites',
                                                          textAlign: TextAlign.center,
                                                          style: TextStyle(
                                                              fontSize: 20.0,
                                                              fontWeight: FontWeight.w600)),
                                                      description: Text(
                                                          "This item will be added to your favourites!"),
                                                      onOkButtonPressed: () {
                                                        Navigator.of(context).pop();
                                                      },
                                                      image: Image(
                                                        image: NetworkImage(
                                                            "http://frogermcs.github.io/images/22/button_anim.gif"),
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ));
                                          },
                                          elevation: 1.0,
                                          fillColor: Color(0xffe5cac2),
                                          child: Icon(
                                            Icons.star,
                                            size: 30.0,
                                            color: AppColors.dietJournalOrange,
                                          ),
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10.0)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.local_fire_department_outlined,
                                        color: AppColors.dietJournalOrange,
                                      ),
                                      SizedBox(
                                        width: 5.0,
                                      ),
                                      RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: '345 ',
                                              style: TextStyle(
                                                  fontSize: 20.0,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.appTextColor),
                                            ),
                                            TextSpan(
                                              text: "Cal",
                                              style: TextStyle(
                                                  color: AppColors.appTextColor, fontSize: 12.0),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.food_bank_outlined,
                                        color: AppColors.dietJournalOrange,
                                      ),
                                      SizedBox(
                                        width: 5.0,
                                      ),
                                      RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: '2000 ',
                                              style: TextStyle(
                                                  fontSize: 20.0,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.appTextColor),
                                            ),
                                            TextSpan(
                                              text: "g",
                                              style: TextStyle(
                                                  color: AppColors.appTextColor, fontSize: 12.0),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "Fitness starts at home. What you eat is what you will look, just as what you sow is what you reap. Eat good food: eat fruits, vegetables, healthy grains, and don't go for sweet and trite food.",
                                          textAlign: TextAlign.justify,
                                          style: TextStyle(fontSize: 16.0),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 15.0, bottom: 15.0),
                                  child: Text(
                                    "Ingredients (12)",
                                    style: TextStyle(
                                        color: AppColors.dietJournalOrange,
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Container(
                                  height: 140.0,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    shrinkWrap: true,
                                    itemCount: ingredientsImages.length,
                                    itemBuilder: (BuildContext context, int index) {
                                      return Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Container(
                                                width: 75.0,
                                                height: 75.0,
                                                decoration: new BoxDecoration(
                                                    borderRadius: BorderRadius.circular(5.0),
                                                    image: new DecorationImage(
                                                        fit: BoxFit.fill,
                                                        image: new NetworkImage(
                                                            ingredientsImages[index])))),
                                          ),
                                          SizedBox(
                                            height: 10.0,
                                          ),
                                          Text(
                                            ingredients[index],
                                            textAlign: TextAlign.justify,
                                            style: TextStyle(fontSize: 18.0),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        Container(
                          width: 160.0,
                          height: 160.0,
                          decoration: ShapeDecoration(
                            shape: CircleBorder(),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(0.0),
                            child: DecoratedBox(
                              decoration: ShapeDecoration(
                                  shape: CircleBorder(),
                                  image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: NetworkImage(
                                        'https://static.toiimg.com/thumb/msid-69095698,imgsize-186609,width-800,height-600,resizemode-75/69095698.jpg',
                                      ))),
                            ),
                          ),
                        )
                      ],
                    ),
                    // Column(
                    //   crossAxisAlignment: CrossAxisAlignment.start,
                    //   children: [
                    //     SizedBox(height: 10.0,),
                    //     Padding(
                    //       padding: const EdgeInsets.all(8.0),
                    //       child: Text(camelize(_typeAheadController.text), style: TextStyle(
                    //           fontSize: 22.0, fontWeight: FontWeight.bold
                    //       ),),
                    //     ),
                    //     SizedBox(height: 5.0,),
                    //     Padding(
                    //       padding: const EdgeInsets.all(8.0),
                    //       child: Row(
                    //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    //         children: [
                    //           Row(
                    //             children: [
                    //               Icon(Icons.local_fire_department_outlined, color: AppColors.primaryAccentColor,),
                    //               SizedBox(width: 5.0,),
                    //               RichText(
                    //                 text: TextSpan(
                    //                   children: [
                    //                     TextSpan(
                    //                       text: '345 ',
                    //                       style: TextStyle(
                    //                           fontSize: 20.0,
                    //                           fontWeight: FontWeight.bold,
                    //                           color: AppColors.appTextColor
                    //                       ),
                    //                     ),
                    //                     TextSpan(
                    //                       text: "kcal",
                    //                       style: TextStyle(
                    //                           color: AppColors.appTextColor,
                    //                           fontSize: 12.0
                    //                       ),
                    //                     ),
                    //                   ],
                    //                 ),
                    //               ),
                    //             ],
                    //           ),
                    //           Row(
                    //             children: [
                    //               Icon(Icons.local_fire_department_outlined, color: AppColors.primaryAccentColor,),
                    //               SizedBox(width: 5.0,),
                    //               RichText(
                    //                 text: TextSpan(
                    //                   children: [
                    //                     TextSpan(
                    //                       text: '2000 ',
                    //                       style: TextStyle(
                    //                           fontSize: 20.0,
                    //                           fontWeight: FontWeight.bold,
                    //                           color: AppColors.appTextColor
                    //                       ),
                    //                     ),
                    //                     TextSpan(
                    //                       text: "g",
                    //                       style: TextStyle(
                    //                           color: AppColors.appTextColor,
                    //                           fontSize: 12.0
                    //                       ),
                    //                     ),
                    //                   ],
                    //                 ),
                    //               ),
                    //             ],
                    //           ),
                    //         ],
                    //       ),
                    //     ),
                    // Padding(
                    //   padding: const EdgeInsets.only(left: 18.0, right: 18.0),
                    //   child: ExpandablePanel(
                    //     controller: _expandableController,
                    //     theme: ExpandableThemeData(
                    //         hasIcon: false, animationDuration: Duration(milliseconds: 100)),
                    //     header: Card(
                    //       color: Color(0xffF4F6FA),
                    //       shape: RoundedRectangleBorder(
                    //         borderRadius: BorderRadius.circular(20.0)
                    //       ),
                    //       child: ListTile(
                    //         leading: Text("1"),
                    //         title: Text("Serving - 2,000 g"),
                    //         trailing: expanded
                    //             ? Icon(Icons.keyboard_arrow_up)
                    //             : Icon(Icons.keyboard_arrow_down),
                    //         onTap: () {
                    //           _expandableController.toggle();
                    //         },
                    //       ),
                    //     ),
                    //     expanded: serving(),
                    //   ),
                    // ),
                    //   ],
                    // ),
                  ],
                ),
              ),
            ),
            Visibility(
              visible: selected ? true : false,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 5.0,
                      ),
                      Text("Nutrition Fact",
                          style: TextStyle(
                              fontSize: 22.0,
                              color: AppColors.dietJournalOrange,
                              fontWeight: FontWeight.bold)),
                      /*SizedBox(
                        height: 15.0,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          CircularPercentIndicator(
                            radius: 100.0,
                            lineWidth: 13.0,
                            animation: true,
                            percent: 0.7,
                            center: new Text(
                              "78%",
                              style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
                            ),
                            footer: new Text(
                              "Carbs",
                              style:
                              new TextStyle(fontWeight: FontWeight.bold, fontSize: 17.0),
                            ),
                            circularStrokeCap: CircularStrokeCap.round,
                            progressColor: Color(0xff7FE3F0),
                          ),
                          CircularPercentIndicator(
                            radius: 100.0,
                            lineWidth: 13.0,
                            animation: true,
                            percent: 0.7,
                            center: new Text(
                              "13%",
                              style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
                            ),
                            footer: new Text(
                              "Proteins",
                              style:
                              new TextStyle(fontWeight: FontWeight.bold, fontSize: 17.0),
                            ),
                            circularStrokeCap: CircularStrokeCap.round,
                            progressColor: Color(0xffAF8EFF),
                          ),
                          CircularPercentIndicator(
                            radius: 100.0,
                            lineWidth: 13.0,
                            animation: true,
                            percent: 0.7,
                            center: new Text(
                              "9%",
                              style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
                            ),
                            footer: new Text(
                              "Fats",
                              style:
                              new TextStyle(fontWeight: FontWeight.bold, fontSize: 17.0),
                            ),
                            circularStrokeCap: CircularStrokeCap.round,
                            progressColor: Color(0xff1F87FE),
                          ),
                        ],
                      ),*/
                      SizedBox(
                        height: 5.0,
                      ),
                      ListTile(
                        // leading: ConstrainedBox(
                        //   constraints: new BoxConstraints(
                        //     minHeight: 20.0,
                        //     minWidth: 20.0,
                        //   ),
                        //   child: new DecoratedBox(
                        //     decoration: new BoxDecoration(color: Color(0xffAF8EFF), borderRadius: BorderRadius.circular(5.0)),
                        //   ),
                        // ),
                        title: Text("Protein",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19.0)),
                        trailing: Text(
                          "4 g",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19.0),
                        ),
                      ),
                      Divider(),
                      ListTile(
                        // leading: ConstrainedBox(
                        //   constraints: new BoxConstraints(
                        //     minHeight: 20.0,
                        //     minWidth: 20.0,
                        //   ),
                        //   child: new DecoratedBox(
                        //     decoration: new BoxDecoration(color: Color(0xff7FE3F0), borderRadius: BorderRadius.circular(5.0)),
                        //   ),
                        // ),
                        title: Text("Carbs",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19.0)),
                        trailing: Text(
                          "44 g",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19.0),
                        ),
                      ),
                      ListTile(
                        title: Text("Fibers", style: TextStyle(fontSize: 19.0)),
                        trailing: Text(
                          "4 g",
                          style: TextStyle(fontSize: 19.0),
                        ),
                      ),
                      ListTile(
                        title: Text("Sugars", style: TextStyle(fontSize: 19.0)),
                        trailing: Text(
                          "40 g",
                          style: TextStyle(fontSize: 19.0),
                        ),
                      ),
                      Divider(),
                      ListTile(
                        // leading: ConstrainedBox(
                        //   constraints: new BoxConstraints(
                        //     minHeight: 20.0,
                        //     minWidth: 20.0,
                        //   ),
                        //   child: new DecoratedBox(
                        //     decoration: new BoxDecoration(color: Color(0xff1F87FE), borderRadius: BorderRadius.circular(5.0)),
                        //   ),
                        // ),
                        title: Text("Fats",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19.0)),
                        trailing: Text(
                          "2 g",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19.0),
                        ),
                      ),
                      ListTile(
                        title: Text("Saturated fat", style: TextStyle(fontSize: 19.0)),
                        trailing: Text(
                          "1.2 g",
                          style: TextStyle(fontSize: 19.0),
                        ),
                      ),
                      ListTile(
                        title: Text("Unsaturated fat", style: TextStyle(fontSize: 19.0)),
                        trailing: Text(
                          "0.8 g",
                          style: TextStyle(fontSize: 19.0),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: Container(
                            height: 50.0,
                            width: 200.0,
                            child: GestureDetector(
                              onTap: () {},
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.dietJournalOrange,
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Center(
                                      child: Text(
                                        "Add to Journal",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Color.fromRGBO(255, 255, 255, 1),
                                            fontFamily: 'Poppins',
                                            fontSize: 18,
                                            letterSpacing: 0.2,
                                            fontWeight: FontWeight.bold,
                                            height: 1),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget serving() {
    return AlertDialog(
      content: Column(
        children: [
          Text("Serving - 3000 g"),
          Text("Serving - 4000 g"),
        ],
      ),
    );
  }
}

class FoodItems {
  var food = [];
  List<String> matches = <String>[];
  http.Client _client = http.Client(); //3gb
  getFromAPI(String foodItem) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var data = prefs.get('data');
    Map res = jsonDecode(data);
    var ihlUserID = res['User']['id'];
    final response = await _client.get(
        Uri.parse(API.iHLUrl +
            '/foodjournal/list_of_food_items_starts_with?search_string=' +
            foodItem +
            '&ihl_user_id=' +
            ihlUserID +
            '&is_advance_search=true'),
        headers: {
          'Content-Type': 'application/json',
          'ApiToken': '${API.headerr['ApiToken']}',
          'Token': '${API.headerr['Token']}',
        });
    if (response.statusCode == 200) {
      food = jsonDecode(response.body);
    }

    print(food);
    for (int i = 0; i < food.length; i++) {
      matches.add(food[i]['item_name'].toString());
    }
    print(matches);
    matches.retainWhere((s) => s.toLowerCase().contains(foodItem.toLowerCase()));
  }

  List<String> getSuggestions(String query) {
    getFromAPI(query);
    return matches;
  }
}

class Food {
  static final List<String> food = [
    'Rice',
    'White Rice',
    'Rice With Vegetables',
    'Rice Noodles',
    'Instant Fried Rice',
    'Richmond',
  ];

  List<String> getSuggestions(String query) {
    List<String> matches = <String>[];
    matches.addAll(food);

    matches.retainWhere((s) => s.toLowerCase().contains(query.toLowerCase()));
    return matches;
  }
}
