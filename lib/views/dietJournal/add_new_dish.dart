// ignore_for_file: unused_import, unused_local_variable, unused_field, camel_case_types, unnecessary_statements, non_constant_identifier_names
import 'dart:convert';
import 'dart:io';

import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'package:ihl/constants/api.dart';
import 'package:ihl/utils/ScUtil.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/views/dietJournal/DietJournalUI.dart';
import 'package:ihl/views/dietJournal/add_ingredients.dart';
import 'package:ihl/views/dietJournal/dietJournal.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'calorie_graph.dart';

class listData extends ChangeNotifier {
  var a = [];
  void changeListData(Map map1, String action) {
    if (action == 'add') {
      a.add(map1);
      notifyListeners();
    } else {
      a.removeWhere((e) => e['item'] == map1['item']);
      notifyListeners();
    }
  }
}

class AddNewDish extends StatefulWidget {
  @override
  _AddNewDishState createState() => _AddNewDishState();
}

class _AddNewDishState extends State<AddNewDish> {
  final TextEditingController _typeAheadController = TextEditingController();
  bool selected = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKey2 = GlobalKey<FormState>();
  FocusNode typeAheadFocus = new FocusNode();
  var quantityOfDish;
  var favDish = [];
  List labels = ['Dish Name', 'Select Unit', 'Quantity', 'Indgredients', 'Notes', 'Ideal Time'];
  String label = 'Dish Name';
  bool imageSelected = false;
  CroppedFile cropedFile;
  File _image;
  String base64Image;
  final picker = ImagePicker();
  static final List<String> unitDropDownItems = ['Cup', 'Gram'];
  String actualUnitDropdown = unitDropDownItems[0];
  bool isLoading = false;
  String dishName; // = "Salad with wheat and white egg";
  String calorieInDish; // = '120';
  var mineralsInDish = []; // = {'protien':60,'Carbs':80,'fat':30};
  var notesForDish; // = "Eggs are a nutritious food, packed with high-quality protein, vitamins and minerals. Eggs may be a concern because they contain large amounts of cholesterol and saturated fats, but the good news is that the fat content is all stored in the yellow part of the eggs.";
  var ingredientsForDish = [];
  var idealsForTime = ['BreakFast', 'Lunch', 'Snacks', 'Dinner'];
  var txt;
  bool completed = false;
  bool quantity = false;
  bool showDoneButtonForIngredients = false;
  var editing = false;
  var iHLUserId;
  // TextEditingController addNewDishController ;
  final addNewDishController = TextEditingController();
  final quantityController = TextEditingController();
  void userId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var data = prefs.get('data');
    // var apiToken = prefs.get('auth_token');
    Map res = jsonDecode(data);
    iHLUserId = res['User']['id'];
  }

  @override
  _imgFromCamera() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    _image = new File(pickedFile.path);

    cropedFile = await ImageCropper().cropImage(
        sourcePath: _image.path,
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
        maxWidth: 512,
        maxHeight: 512,
        compressFormat: ImageCompressFormat.png,
        compressQuality: 60,
        uiSettings: [
          AndroidUiSettings(
            lockAspectRatio: false,
            activeControlsWidgetColor: AppColors.primaryAccentColor,
            toolbarTitle: 'Crop the Image',
            toolbarColor: Color(0xFF19a9e5),
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
          ),
          IOSUiSettings(title: 'Crop the Image', aspectRatioLockEnabled: true)
        ]);

    if (this.mounted) {
      setState(() {
        List<int> imageBytes = File(cropedFile.path).readAsBytesSync();
        base64Image = base64.encode(imageBytes);
        imageSelected = true;
      });
    }
  }

  _imgFromGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    _image = File(pickedFile.path);

    cropedFile = await ImageCropper().cropImage(
      sourcePath: _image.path,
      aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
      maxWidth: 512,
      maxHeight: 512,
      compressFormat: ImageCompressFormat.png,
      compressQuality: 60,
      uiSettings: [
        AndroidUiSettings(
          lockAspectRatio: false,
          activeControlsWidgetColor: AppColors.primaryAccentColor,
          toolbarTitle: 'Crop the Image',
          toolbarColor: Color(0xFF19a9e5),
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
        ),
        IOSUiSettings(title: 'Crop the Image', aspectRatioLockEnabled: true)
      ],
    );

    if (this.mounted) {
      setState(() {
        List<int> imageBytes = File(cropedFile.path).readAsBytesSync();
        base64Image = base64.encode(imageBytes);
        imageSelected = true;
      });
    }
  }

  void _showPicker(context) {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.0),
        ),
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text('Photo Library'),
                      onTap: () {
                        _imgFromGallery();
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('Camera'),
                    onTap: () {
                      _imgFromCamera();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  void initState() {
    userId();
    super.initState();
  }

  http.Client _client = http.Client(); //3gb
  void ingredientDetails1() async {
    // ingredientsForDish.length>0?ingredientsForDish[index]:'',
    if (false == true) {
      //For Now Ingredient id is manual , but after that we have to search and give item id dynamicaaly
      final response = await _client.get(
        Uri.parse(API.iHLUrl +
            "/consult/get_ingredient_details?ingredient_item_id=8&ihl_user_id=$iHLUserId"),
        headers: {
          'Content-Type': 'application/json',
          'ApiToken': '${API.headerr['ApiToken']}',
          'Token': '${API.headerr['Token']}',
        },
      );

      if (response.statusCode == 200) {
        // setState(() {
        // ingredientDetailsFromApi
        // var res = {};
        ingredientDetailsFromApi = json.decode(response.body);
        // for(int i =0;i<res.length;i++){
        ingredientDetailsFromApi.removeWhere((key, value) =>
            key == 'id' ||
            key == 'item' ||
            key == 'sno' ||
            key == 'PartitionKey' ||
            key == 'RowKey' ||
            key == 'Timestamp' ||
            key == 'ETag');

        if (mounted) {
          setState(() {
            ingredientDetailsFromApi;
            Provider.of<listData>(context).changeListData(ingredientDetailsFromApi, 'add');

            // a.add(ingredientDetailsFromApi);
            // a = [ingredientDetailsFromApi];
          });
        }
        // }
      }
    } else {
      print('response failure for details of Ingredients API cause status code is' + '400');
      // response.statusCode.toString());
    }
    ingredientDetailsFromApi = {
      'Protien': '3 % ',
      'Fat': '4 %',
      'Carbs': '7 %',
      'calorie': '120',
      'item': _typeAheadController.text,
      // 'image':ingredientsImages[a.length!=null?a.length:0],
    };
    if (this.mounted) {
      setState(() {
        Provider.of<listData>(context, listen: false)
            .changeListData(ingredientDetailsFromApi, 'add');
        // a.add(ingredientDetailsFromApi);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DietJournalUI(
      appBar: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back_ios),
                  onPressed: () => Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => DietJournal()),
                      // (introDone: true)),
                      (Route<dynamic> route) => false),
                  color: Colors.white,
                  tooltip: 'Back',
                ),
                // Flexible(
                //   child: Center(
                //     child: Text(
                //       'Journal',
                //       style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                //       textAlign: TextAlign.center,
                //     ),
                //   ),
                // ),
                Text(
                  'Add Meal',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: ScUtil().setSp(22),
                    color: Colors.white,
                  ),
                ),
                SizedBox(
                  width: 40,
                )
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          color: AppColors.cardColor,
          padding: const EdgeInsets.only(left: 8.0),
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 15.0, bottom: 12),
                child: Visibility(
                  visible: label == '' ? false : true,
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Visibility(
                              visible: label == 'Dish Image',
                              child: Column(
                                children: [
                                  SizedBox(height: 20), // ScUtil().setHeight(20.0)),
                                  Visibility(
                                    visible: imageSelected ? false : true,
                                    child: Text(
                                      "Select Meal Image",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                  CircleAvatar(
                                    backgroundColor: Colors.white,
                                    radius: 40,
                                    child: cropedFile != null
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.circular(50),
                                            child: Image.file(
                                              File(cropedFile.path),
                                              width: 500.0,
                                              height: 300.0,
                                              fit: BoxFit.fitHeight,
                                            ),
                                          )
                                        : IconButton(
                                            padding: EdgeInsets.zero,
                                            icon: Center(
                                              child: Icon(
                                                Icons.cloud_upload,
                                                size: 40,
                                              ), //ScUtil().setHeight(50.0)),
                                            ),
                                            onPressed: () {
                                              _showPicker(context);
                                            },
                                          ),
                                  ),
                                  SizedBox(
                                    height: 10, //ScUtil().setHeight(10),
                                  ),
                                  GestureDetector(
                                      onTap: () => _showPicker(context),
                                      child: Text(
                                        _image == null ? "Select Meal Image" : "Change",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20, //ScUtil().setSp(20.0),
                                          color: Color(0xff6d6e71),
                                        ),
                                      )),
                                  // SizedBox(
                                  //   height: 20,
                                  // ) //ScUtil().setHeight(20.0)),
                                ],
                              ),
                            ),

                            //serach field
                            Visibility(
                              visible: label == 'Indgredients',
                              child: Form(
                                key: _formKey,
                                child: Theme(
                                  data: ThemeData(
                                    primaryColor: AppColors.dietJournalOrange,
                                    focusColor: AppColors.dietJournalOrange,
                                    fixTextFieldOutlineLabel: true,
                                  ),
                                  child: TypeAheadFormField(
                                    textFieldConfiguration: TextFieldConfiguration(
                                        focusNode: typeAheadFocus,
                                        cursorColor: AppColors.dietJournalOrange,
                                        controller: this._typeAheadController,
                                        decoration: InputDecoration(
                                          labelStyle: typeAheadFocus.hasPrimaryFocus
                                              ? TextStyle(
                                                  color: AppColors.dietJournalOrange,
                                                )
                                              : TextStyle(),
                                          // enabledBorder: OutlineInputBorder(
                                          //   borderRadius:
                                          //       const BorderRadius.all(
                                          //           const Radius.circular(
                                          //               20.0)),
                                          //   borderSide: BorderSide(
                                          //       color: AppColors
                                          //           .dietJournalOrange),
                                          // ),
                                          // focusedBorder: OutlineInputBorder(
                                          //   borderRadius:
                                          //       const BorderRadius.all(
                                          //           const Radius.circular(
                                          //               20.0)),
                                          //   borderSide: BorderSide(
                                          //       color: AppColors
                                          //           .dietJournalOrange),
                                          // ),
                                          border: new OutlineInputBorder(
                                              borderRadius: const BorderRadius.all(
                                                  const Radius.circular(20.0))),
                                          labelText: 'Indgredients',
                                          prefixIcon: Padding(
                                            padding: const EdgeInsetsDirectional.only(end: 8.0),
                                            child: Icon(Icons.search),
                                          ),
                                        )),
                                    suggestionsCallback: (pattern) {
                                      return CitiesService.getSuggestions(pattern);
                                    },
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
                                    validator: (value) {
                                      if (value.isEmpty) {
                                        return 'Please select ' + 'Ingredient';
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
                                                    'Add Ingredient ?',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        color: AppColors.appTextColor,
                                                        fontSize: 18.0),
                                                  ),
                                                  //  Text(
                                                  //   '', //'Ingredient Not Found!',//'No Food item Found!',
                                                  //   textAlign: TextAlign.center,
                                                  //   style: TextStyle(
                                                  //       color: AppColors
                                                  //           .appTextColor,
                                                  //       fontSize: 18.0),
                                                  // ),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.spaceEvenly,
                                                    children: [
                                                      ElevatedButton(
                                                        onPressed: () {
                                                          FocusScopeNode currentFocus =
                                                              FocusScope.of(context);
                                                          if (!currentFocus.hasPrimaryFocus) {
                                                            currentFocus.unfocus();
                                                          }
                                                          Navigator.of(context).push(
                                                            MaterialPageRoute(
                                                                builder: (context) =>
                                                                    AddIngredient()),
                                                          );
                                                          // addIngredients(context);
                                                          // showBottomSheet();
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
                                                          FocusScopeNode currentFocus =
                                                              FocusScope.of(context);
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
                              ),
                            ),

                            //search button

                            //     Visibility(
                            //       visible: false,
                            //       child: ElevatedButton(
                            //   color: AppColors.primaryAccentColor,
                            //   textColor: Colors.white,
                            //   child: Text('Search'),
                            //   onPressed: () {
                            //       // if (this._formKey.currentState.validate()) {
                            //       //   this._formKey.currentState.save();
                            //       //   Navigator.of(context).push(MaterialPageRoute(
                            //       //       builder: (context) => SetPortionSize(
                            //       //         foodName: this._typeAheadController.text,
                            //       //       )));
                            //       // }
                            //   },
                            // ),
                            //     ),

                            // add quantity button
                            //  Visibility(
                            //         visible:false,//label == 'Indgredients' && ingredientsForDish.length ==
                            //          child: TextFormField(
                            //         controller: quantityController,
                            //         onChanged: (v){
                            //            txt = v;
                            //         },
                            //         // autofocus: false,
                            //         validator: (value) {
                            //           if (value.isEmpty) {
                            //             return 'Please enter something!';
                            //           }
                            //           return null;
                            //         },
                            //         decoration: InputDecoration(
                            //           contentPadding:EdgeInsets.symmetric(vertical: 18.0, horizontal: 15.0),
                            //           // prefixIcon: Padding(
                            //           //   padding: const EdgeInsetsDirectional.only(end: 8.0),
                            //           //   child: Icon(Icons.search),
                            //           // ),
                            //           labelText: 'quantity[in gram]',
                            //           fillColor: Colors.white,
                            //           border: new OutlineInputBorder(
                            //               borderRadius: new BorderRadius.circular(15.0),
                            //               borderSide: new BorderSide(color: Colors.blueGrey)),
                            //         ),
                            //         maxLines: 1,
                            //         style: TextStyle(fontSize: 16.0),
                            //         textInputAction: TextInputAction.done,

                            // ),
                            //       ),

                            // add dish name and all
                            Visibility(
                              visible: label == 'Indgredients' ||
                                      label == 'Ideal Time' ||
                                      label == 'Select Unit'
                                  ? false
                                  : true,
                              child: Form(
                                key: _formKey2,
                                child: Theme(
                                  data: ThemeData(
                                    primaryColor: AppColors.dietJournalOrange,
                                    focusColor: AppColors.dietJournalOrange,
                                    fixTextFieldOutlineLabel: true,
                                  ),
                                  child: TextFormField(
                                    controller: addNewDishController,
                                    validator: (v) {
                                      if (v.isEmpty) {
                                        return 'Please enter something!';
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                      contentPadding:
                                          EdgeInsets.symmetric(vertical: 18.0, horizontal: 15.0),
                                      prefixIcon: Padding(
                                        padding: const EdgeInsetsDirectional.only(end: 8.0),
                                        child: Icon(Icons.search),
                                      ),
                                      labelText: label != 'Quantity'
                                          ? '$label'
                                          : '$label in $actualUnitDropdown',
                                      fillColor: Colors.white,
                                      border: new OutlineInputBorder(
                                          borderRadius: new BorderRadius.circular(15.0),
                                          borderSide: new BorderSide(color: Colors.blueGrey)),
                                    ),
                                    maxLines: 1,
                                    style: TextStyle(fontSize: 16.0),
                                    textInputAction: TextInputAction.done,
                                  ),
                                ),
                              ),
                            ),
                            //'Ideal Time'
                            Visibility(
                              visible: label == 'Ideal Time',
                              child: Wrap(
                                children: [
                                  //  Text('Select Ideal Time),
                                  idealForTime(0, 'B'),
                                  SizedBox(
                                    width: 7,
                                  ),
                                  idealForTime(1, 'L'),
                                  idealForTime(2, 'S'),
                                  SizedBox(
                                    width: 7,
                                  ),
                                  idealForTime(3, 'D'),
                                ],
                              ),
                            ),
                            //Drop Down for select unit
                            Visibility(
                              visible: label == 'Select Unit',
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Text(
                                    'Select Unit ',
                                    style: TextStyle(),
                                  ),
                                  DropdownButton(
                                      icon: Icon(Icons.arrow_drop_down),
                                      iconEnabledColor: Colors.grey,
                                      iconDisabledColor: Colors.grey,
                                      dropdownColor: Colors.white,
                                      isDense: true,
                                      underline: SizedBox(),
                                      value: actualUnitDropdown,
                                      onChanged: (String value) {
                                        if (this.mounted) {
                                          setState(() {
                                            actualUnitDropdown = value;
                                          });
                                        }
                                      },
                                      items: unitDropDownItems.map((String title) {
                                        return DropdownMenuItem(
                                          value: title,
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(title,
                                                style: TextStyle(
                                                    // color: AppColors.myApp,
                                                    color: AppColors.dietJournalOrange,
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 14.0)),
                                          ),
                                        );
                                      }).toList()),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Visibility(
                        visible: label == 'Dish Name' ||
                            label == 'Notes' ||
                            label == 'Quantity' ||
                            label == 'Select Unit',
                        child: GestureDetector(
                          onTap: () {
                            if (this.mounted) {
                              setState(() {
                                int i = labels.indexOf('$label');
                                if (label == 'Select Unit') {
                                  label = labels[i + 1];
                                } else {
                                  calorieInDish;
                                  if (editing && _formKey2.currentState.validate()) {
                                    if (this.mounted) {
                                      setState(() {
                                        if (labels[i] == 'Dish Name') {
                                          dishName = addNewDishController.text;
                                        } else if (labels[i] == 'Notes') {
                                          notesForDish = addNewDishController.text;
                                          if (ingredientsForDish.length >= 1) {
                                            calorieInDish =
                                                (int.tryParse(ingredientDetailsFromApi['calorie']) *
                                                        ingredientsForDish.length)
                                                    .toString();
                                          }
                                        }
                                        editing = false;
                                        addNewDishController.clear();
                                        print('if editing true');
                                        label = '';
                                      });
                                    }
                                  } else if (_formKey2.currentState.validate() && !editing) {
                                    print('else if editing false');

                                    if (labels[i] == 'Dish Name') {
                                      dishName = addNewDishController.text;
                                    } else if (labels[i] == 'Notes') {
                                      notesForDish = addNewDishController.text;
                                    } else if (label == 'Quantity') {
                                      quantityOfDish = addNewDishController.text;
                                    }
                                    addNewDishController.clear();
                                    label = labels[i + 1];
                                  }
                                }
                              });
                            }
                          },
                          child: Container(
                            margin: EdgeInsets.only(left: 13),
                            height: 50,
                            width: 50,
                            child: Icon(
                              Icons.add,
                              size: 30.0,
                              color: AppColors.dietJournalOrange,
                              //Color(0xffe5cac2),
                            ),
                            decoration: BoxDecoration(
                                color: Color(0xffe5cac2),
                                //AppColors.customButtonTextColor,//Colors.redAccent,
                                borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(17), topLeft: Radius.circular(17))),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: label == 'Indgredients' || label == 'Ideal Time',
                        child: Column(
                          children: [
                            Visibility(
                              visible: label != 'Ideal Time',
                              child: GestureDetector(
                                onTap: () {
                                  ingredientDetails1();
                                  if (this.mounted) {
                                    setState(() {
                                      // calorieInDish;
                                      if (label == 'Indgredients' &&
                                          _formKey.currentState.validate()) {
                                        ingredientsForDish.add(_typeAheadController.text);
                                        //an api will call every time you add ingredients
                                        if (ingredientsForDish.length >= 1) {
                                          calorieInDish =
                                              (int.tryParse(ingredientDetailsFromApi['calorie']) *
                                                      ingredientsForDish.length)
                                                  .toString();
                                        }
                                        _typeAheadController.clear();
                                      }
                                    });
                                  }
                                },
                                child: Container(
                                  margin: EdgeInsets.only(left: 13),
                                  height: 45,
                                  width: 50,
                                  child: Icon(
                                    Icons.add,
                                    size: 30.0,
                                    color: AppColors.dietJournalOrange,
                                  ),
                                  decoration: BoxDecoration(
                                      color: Color(0xffe5cac2),
                                      borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(17),
                                          topLeft: Radius.circular(17))),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Visibility(
                              visible: true,
                              child: GestureDetector(
                                onTap: () {
                                  if (this.mounted) {
                                    setState(() {
                                      if (editing) {
                                        if (label == 'Ideal Time') {
                                          label = '';
                                          editing = false;
                                        }

                                        if (label == 'Indgredients') {
                                          label = '';
                                          editing = false;
                                        }
                                      } else if (!editing) {
                                        int i = labels.indexOf(label);
                                        if (i == labels.length - 1) {
                                          completed = true;
                                          label = '';
                                        } else {
                                          label = labels[i + 1];
                                          // if (label == 'Notes') {
                                          //   if (ingredientsForDish.length >= 1) {
                                          //     calorieInDish =
                                          //         (int.tryParse(ingredientDetailsFromApi[
                                          //                     'calories']) *
                                          //                 ingredientsForDish
                                          //                     .length)
                                          //             .toString();
                                          //   }
                                          // }
                                        }
                                      }
                                    });
                                  }
                                },
                                child: Container(
                                  margin: EdgeInsets.only(left: 13),
                                  height: 45,
                                  width: 50,
                                  child: Icon(
                                    Icons.done_rounded, size: 30.0,
                                    color: AppColors.dietJournalOrange,
                                    //Color(0xffe5cac2),
                                  ),
                                  decoration: BoxDecoration(
                                      color: Color(0xffe5cac2),
                                      //AppColors.customButtonTextColor,//Colors.redAccent,
                                      borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(17),
                                          topLeft: Radius.circular(17))),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Visibility(
                visible: dishName != null,
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 100 / 4.0), //circle radius
                      child: GestureDetector(
                        onTap: completed
                            ? () {
                                if (this.mounted) {
                                  setState(() {
                                    editing = true;
                                  });
                                }
                                edit('Dish Name');
                              }
                            : () {},
                        child: Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                          color: Colors.white,
                          child: Column(
                            children: [
                              SizedBox(
                                height: 90.0,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 8.0, top: 8, right: 8, bottom: 0),
                                child: Text(
                                  (dishName != null ? dishName : '').toUpperCase(),
                                  style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 0, bottom: 8, left: 35),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Row(
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
                                                text: calorieInDish != null
                                                    ? '$calorieInDish '
                                                    : '0 ',
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
                                    SizedBox(
                                      width: 70.0,
                                    ),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.food_bank_outlined,
                                          color: AppColors.dietJournalOrange,
                                        ), //.primaryAccentColor,),
                                        SizedBox(
                                          width: 5.0,
                                        ),
                                        RichText(
                                          text: TextSpan(
                                            children: [
                                              TextSpan(
                                                text: quantityOfDish != null
                                                    ? '$quantityOfDish '
                                                    : '', //'2000 ',
                                                style: TextStyle(
                                                    fontSize: 20.0,
                                                    fontWeight: FontWeight.bold,
                                                    color: AppColors.appTextColor),
                                              ),
                                              TextSpan(
                                                text: actualUnitDropdown, //"g",
                                                style: TextStyle(
                                                    color: AppColors.appTextColor, fontSize: 12.0),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Container(
                      //   //replace this Container with your Card
                      //   color: Colors.white,
                      //   height: 200.0,
                      // ),
                    ),
                    Stack(
                      children: [
                        GestureDetector(
                          onTap: () => _showPicker(context),
                          child: Container(
                            width: 120.0,
                            height: 120.0,
                            decoration: ShapeDecoration(
                              shape: CircleBorder(),
                              // color: Color(0xffe5cac2)
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(1),
                              child: DecoratedBox(
                                decoration: ShapeDecoration(
                                  shape: CircleBorder(),
                                  image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: cropedFile != null
                                        ? FileImage(File(cropedFile.path))
                                        : NetworkImage(
                                            'https://static.toiimg.com/thumb/msid-69095698,imgsize-186609,width-800,height-600,resizemode-75/69095698.jpg',
                                          ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 3,
                          child: CircleAvatar(
                            child: IconButton(
                              icon: Center(
                                child: Icon(
                                  Icons.add_a_photo_outlined,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                              onPressed: () {
                                _showPicker(context);
                              },
                            ),
                            backgroundColor: Colors.orange,
                            radius: 16,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),

              /// ingradients list
              Visibility(
                visible: ingredientsForDish.length >= 1,
                child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    color: Colors.white, //AppColors.cardColor,
                    child: Column(children: [
                      ListTile(
                        title: Padding(
                          padding: const EdgeInsets.only(left: 8.0, top: 5, bottom: 3),
                          child: Row(
                            children: [
                              Text(
                                "Ingredients",
                                style: TextStyle(
                                    letterSpacing: 1.0,
                                    color: AppColors.appTextColor,
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.justify,
                              ),
                              SizedBox(
                                width: 150,
                              ),
                              // Icon(Icons.remove_circle,),
                              Container(
                                width: 31.5,
                                height: 31.5,
                                child: RawMaterialButton(
                                  onPressed: completed
                                      ? () {
                                          if (this.mounted) {
                                            setState(() {
                                              editing = true;
                                              label = 'Indgredients';
                                            });
                                          }
                                        }
                                      : () {},
                                  elevation: 1.0,
                                  fillColor: Color(0xffe5cac2),
                                  child: Icon(
                                    Icons.add,
                                    size: 27.0,
                                    color: AppColors.dietJournalOrange,
                                  ),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0)),
                                ),
                              ),
                            ],
                          ),
                        ),

                        subtitle: Column(
                          children: Provider.of<listData>(context).a.reversed.map((f) {
                            return IngredientsJournalEntry(
                              data: f,
                              bottom: scrolltoBottom,
                            );
                            // ecgGraphData: f['graphECG']);
                          }).toList(),
                        ),
                        // child: Column(
                        //   children: [
                        //     ListTile(
                        // title: Padding(
                        //   padding: const EdgeInsets.all(8.0),
                        //   child: Text(
                        //     "Ingredients", style: TextStyle(
                        //     letterSpacing: 1.0,
                        //     color: AppColors.appTextColor,
                        //     fontSize: 15.0,
                        //       fontWeight: FontWeight.bold
                        //   ),
                        //     textAlign: TextAlign.justify,
                        //   ),
                        // ),
                        //   subtitle: Column(
                        //     children: [
                        //       SizedBox(
                        //   height: 10.0,
                        // ),

                        //         ],
                        //       ),
                        //     ),
                        //     SizedBox(
                        //       height: 5.0,
                        //     ),

                        //   ],
                        // ),
                      ),
                    ])),
              ),

              //Notes For Dish
              Visibility(
                visible: notesForDish != null,
                child: GestureDetector(
                  onTap: completed
                      ? () {
                          if (this.mounted) {
                            setState(() {
                              editing = true;
                              edit('Notes');
                            });
                          }
                        }
                      : () {},
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    color: Colors.white, //AppColors.cardColor,
                    child: Column(
                      children: [
                        ListTile(
                          title: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Notes",
                              style: TextStyle(
                                  letterSpacing: 1.0,
                                  color: AppColors.appTextColor,
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.w600),
                              textAlign: TextAlign.justify,
                            ),
                          ),
                          subtitle: Column(
                            children: [
                              SizedBox(
                                height: 5.0,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 5.0, right: 0, left: 7),
                                child: Text(
                                  notesForDish != null ? notesForDish : '',
                                  style: TextStyle(color: AppColors.appTextColor),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 5.0,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              Visibility(
                visible: _filters.length > 0, //idealsForTime!=null,
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  color: Colors.white, //AppColors.cardColor,
                  child: Column(
                    children: [
                      ListTile(
                        onTap: () {
                          if (this.mounted) {
                            setState(() {
                              editing = true;
                              label = 'Ideal Time';
                            });
                          }
                        },
                        title: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Ideal Time",
                            style: TextStyle(
                                letterSpacing: 1.0,
                                color: AppColors.appTextColor,
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.justify,
                          ),
                        ),
                        subtitle: Column(
                          children: [
                            SizedBox(
                              height: 10.0,
                            ),
                            Visibility(
                              visible: _filters.length > 0,
                              child: Wrap(
                                children: [
                                  //  Text('Select Ideal Time'),
                                  // idealForTimes(_filters[i],'B'),
                                  //   SizedBox(width: 7,),

                                  _filters.length > 0 ? idealForTimeSelected(0, 'B') : SizedBox(),
                                  SizedBox(
                                    width: 7,
                                  ),
                                  _filters.length > 1 ? idealForTimeSelected(1, 'L') : SizedBox(),
                                  SizedBox(
                                    width: 7,
                                  ),
                                  _filters.length > 2 ? idealForTimeSelected(2, 'S') : SizedBox(),
                                  SizedBox(
                                    width: 7,
                                  ),
                                  _filters.length > 3 ? idealForTimeSelected(3, 'D') : SizedBox(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 5.0,
                      ),
                    ],
                  ),
                ),
              ),

              Visibility(
                visible: completed && !editing,
                child: GestureDetector(
                  onTap: () async {
                    // isLoading = true;
                    if (this.mounted) {
                      setState(() {
                        isLoading = true;
                      });
                    }
                    if (false == true) {
                      final response = await _client.get(
                        Uri.parse(API.iHLUrl +
                            "/consult/bookmark_food_item_to_user?food_item_id=2&ihl_user_id=$iHLUserId"),
                        headers: {
                          'Content-Type': 'application/json',
                          'ApiToken': '${API.headerr['ApiToken']}',
                          'Token': '${API.headerr['Token']}',
                        },
                      );

                      if (response.statusCode == 200) {
                        // setState(() {
                        var result = json.decode(response.body);
                        if (this.mounted) {
                          setState(() {
                            isLoading = false;
                          });
                        }
                      } else {
                        print('response failure for mark favourite cause status code is' +
                            response.statusCode.toString());
                      }
                    }
                    if (this.mounted) {
                      setState(() {
                        label = 'Dish Name';

                        //  isLoading=false;
                        dishName = null; // = "Salad with wheat and white egg";
                        calorieInDish = null; // = '120';
                        // = {'protien':60,'Carbs':80,'fat':30};
                        notesForDish =
                            null; // = "Eggs are a nutritious food, packed with high-quality protein, vitamins and minerals. Eggs may be a concern because they contain large amounts of cholesterol and saturated fats, but the good news is that the fat content is all stored in the yellow part of the eggs.";
                        ingredientsForDish = [];
                        idealsForTime = ['BreakFast', 'Lunch', 'Snacks', 'Dinner'];
                        completed = false;
                        quantity = false;
                        showDoneButtonForIngredients = false;
                        editing = false;
                        _filters = [];
                      });
                    }
                  },
                  child: Container(
                    height: 50,
                    margin: EdgeInsets.only(bottom: 15, top: 5, left: 4.5, right: 5.4),
                    decoration: BoxDecoration(
                      color: //Colors.deepOrange,
                          //Color(0xffe5cac2),//
                          AppColors.dietJournalOrange,
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Center(
                          child: isLoading == true
                              ? new CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                )
                              : Text(
                                  'Add Meal',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Color.fromRGBO(255, 255, 255, 1),
                                      fontFamily: 'Poppins',
                                      fontSize: ScUtil().setSp(16),
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
            ],
          ),
        ),
      ),
    );
  }

  ScrollController _scrollController = ScrollController();
  scrolltoBottom(int pos) {
    Future.delayed(Duration(milliseconds: 100)).then((value) {
      _scrollController.animateTo(_scrollController.offset + pos,
          duration: Duration(milliseconds: 100), curve: Curves.linear);
    });
  }

  ExpandableController _controller = ExpandableController();
  Widget tableBuilder({Map data, index}) {
    List<DataRow> rows = [];
    data.forEach((k, v) {
      rows.add(
        DataRow(cells: [
          DataCell(
            Text(
              k.toString(),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          DataCell(
            Text(v.toString()),
          )
        ]),
      );
    });
    return Center(
      child: Row(
        children: [
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  rows: rows,
                  headingRowHeight: 18,
                  columns: [
                    DataColumn(
                        label: Icon(
                      Icons.east,
                      color: Colors.transparent,
                      size: 0,
                    )
                        // ingredientsForDish.length>0? 'Nutrition Fact of ${ingredientsForDish[index]} per 1 gram'
                        // ),
                        // ${ingredientsForDish[index]}
                        ),
                    DataColumn(
                        label: Icon(
                      Icons.east,
                      color: Colors.transparent,
                      size: 0,
                    ))
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  var ingredientDetailsFromApi = {}; //{'Protien':'3 % ', 'Fat':'4 %','Carbs':'7 %'};

  var _filters = [];

  Widget idealForTime(int index, String i) {
    return FilterChip(
      backgroundColor: Color(0xffe5cac2), //AppColors.buttonBackgroundColor,
      avatar: CircleAvatar(
          backgroundColor: Color(0xffe5cac2), //Colors.lightBlue[50],
          child: Icon(
            index == 0
                ? Icons.free_breakfast_outlined
                : index == 1
                    ? Icons.lunch_dining
                    : index == 2
                        ? Icons.food_bank_outlined
                        : index == 3
                            ? Icons.local_dining_rounded
                            : Icons.wysiwyg_outlined,
            color: AppColors.dietJournalOrange,
          )
          // Text(i.toUpperCase(),style: TextStyle(color: Colors.white),),
          ),
      label: Text(idealsForTime[index], style: TextStyle(color: Colors.black)),
      selected: _filters != null ? _filters.contains(idealsForTime[index]) : false,
      selectedColor: AppColors.dietJournalOrange,
      onSelected: (bool selected) {
        if (this.mounted) {
          setState(() {
            if (selected) {
              _filters.add(idealsForTime[index]);
            } else {
              _filters.removeWhere((name) {
                return name == idealsForTime[index];
              });
            }
            print(_filters);
          });
        }
      },
    );
  }

  Widget idealForTimeSelected(index, i) {
    return FilterChip(
      backgroundColor: AppColors.buttonBackgroundColor,
      avatar: CircleAvatar(
          backgroundColor: Colors.lightBlue[50],
          // child:Icon(index==0?Icons.free_breakfast_outlined:index==1?Icons.lunch_dining:index==2?Icons.food_bank_outlined:index==3?Icons.local_dining_rounded:Icons.wysiwyg_outlined)
          // Text(i.toUpperCase(),style: TextStyle(color: Colors.white),),
          child: Text('')),
      label: Text(
        _filters.length > 0 ? _filters[index] : '',
        style: TextStyle(color: Colors.white),
      ),
      selected:
          _filters != null ? _filters.contains(_filters.length > 0 ? _filters[index] : '') : false,
      selectedColor: AppColors.dietJournalOrange,
      onSelected: (bool selected) {
        //   setState(() {
        //     if (selected) {
        //       _filters.add(idealsForTime[index]);
        //     } else {
        //        _filters.removeWhere((name) {
        //         return name == idealsForTime[index];
        //       });
        //     }
        //     print(_filters);
        //   });
      },
    );
  }

  void edit(String dishLabel) {
    setState(() {
      label = dishLabel;
      if (label == 'Dish Name') {
        addNewDishController.text = dishName;
      } else if (label == 'Notes') {
        addNewDishController.text = notesForDish;
      }
    });
  }
}

class CitiesService {
  static final List<String> food = [
    'rice',
    'white rice',
    'rice with vegetables',
    'rice noodles',
    'instant fried rice',
    'richmond',
  ];

  static Future<List<String>> getSuggestions(String query) async {
    List<String> matches = <String>[];
    //matches.addAll(food);
    var test = true;
    var match = [];
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // var data = prefs.get('data');
    // Map res = jsonDecode(data);
    // var iHLUserId = res['User']['id'];
    if (test == true) {
      http.Client _client = http.Client(); //3gb
      final response = await _client.get(
          Uri.parse(API.iHLUrl +
              "/consult/list_of_ingredient_starts_with?search_string=$query&ihl_user_id=abc"),
          headers: {
            'Content-Type': 'application/json',
            'ApiToken': '${API.headerr['ApiToken']}',
            'Token': '${API.headerr['Token']}',
          });

      if (response.statusCode == 200) {
        // setState(() {
        match = json.decode(response.body);
        for (int i = 0; i < match.length; i++) {
          matches.add(match[i]["item_name"]);
        }
        // });
      } else {
        print('response failure for Search API cause status code is' +
            response.statusCode.toString());
      }
    }
    matches.retainWhere((s) => s.toLowerCase().contains(query.toLowerCase()));
    return matches;
  }
}
