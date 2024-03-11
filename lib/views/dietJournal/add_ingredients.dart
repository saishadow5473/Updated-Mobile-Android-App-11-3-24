// import 'package:customgauge/customgauge.dart';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ihl/constants/api.dart';
import 'package:ihl/utils/ScUtil.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/views/dietJournal/DietJournalUI.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class AddIngredient extends StatefulWidget {
  @override
  _AddIngredientState createState() => _AddIngredientState();
}

class _AddIngredientState extends State<AddIngredient> {
  http.Client _client = http.Client(); //3gb
  var a = [];
  var ingredientsForDish = [];
  final TextEditingController _typeAheadController = TextEditingController();
  bool selected = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKey2 = GlobalKey<FormState>();
  FocusNode typeAheadFocus = new FocusNode();

  var favDish = []; //'Dish Image',
  List labels = [
    'Ingredient Name',
    // 'Dish Image',
    'Ingredient Detail',
  ];
  String label = 'Ingredient Name';
  bool imageSelected = false;
  CroppedFile ingredientsCroppedFile;
  File _image;
  String base64Image;
  final picker = ImagePicker();
  bool isLoading = false;
  String indgredientName; // = "Salad with wheat and white egg";
  String calorieInIngredient; // = '120';
  var indgredientDetails = {}; // = {'protien':60,'Carbs':80,'fat':30};
  bool completed = false;
  bool quantity = false;
  bool editing = false;
  final addIngredientController = TextEditingController();
  final quantityController = TextEditingController();

  _imgFromCamera() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    _image = new File(pickedFile.path);
    ingredientsCroppedFile = await ImageCropper().cropImage(
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
        IOSUiSettings(title: 'Crop the Image', aspectRatioLockEnabled: true),
      ],
    );

    if (this.mounted) {
      setState(() {
        List<int> imageBytes = File(ingredientsCroppedFile.path).readAsBytesSync();
        base64Image = base64.encode(imageBytes);
        imageSelected = true;
      });
    }
  }

  _imgFromGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    _image = File(pickedFile.path);

    ingredientsCroppedFile = await ImageCropper().cropImage(
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
        IOSUiSettings(title: 'Crop the Image', aspectRatioLockEnabled: true),
      ],
    );

    if (this.mounted) {
      setState(() {
        List<int> imageBytes = File(ingredientsCroppedFile.path).readAsBytesSync();
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
    super.initState();
  }

  void ingredientDetails1() async {
    // ingredientsForDish.length>0?ingredientsForDish[index]:'',
    if (false == true) {
      //For Now Ingredient id is manual , but after that we have to search and give item id dynamicaaly
      final response = await _client.get(
        Uri.parse(
            API.iHLUrl + "/consult/get_ingredient_details?ingredient_item_id=8&ihl_user_id=abc"),
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
            a.add(ingredientDetailsFromApi);
            // a = [ingredientDetailsFromApi];
          });
        }
        // }
      }
    } else {
      print('response failure for details of Ingredients API cause status code is' + '400');
      // response.statusCode.toString());
    }
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
        a.add(ingredientDetailsFromApi);
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
                  onPressed: () => Navigator.of(context).pop(),
                  // Navigator.pushAndRemoveUntil(
                  //     context,
                  //     MaterialPageRoute(builder: (context) => DietJournal()),
                  //     // (introDone: true)),
                  //     (Route<dynamic> route) => false),
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
                  'Add Ingredient',
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
                              visible: label == 'Ingredient Detail',
                              child: Form(
                                key: _formKey,
                                child: Theme(
                                  data: ThemeData(
                                    primaryColor: AppColors.dietJournalOrange,
                                    focusColor: AppColors.dietJournalOrange,
                                    fixTextFieldOutlineLabel: true,
                                  ),
                                  child: TextFormField(
                                    controller: addIngredientController,
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
                                      labelText: '$label',
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

                            // add dish name and all
                            Visibility(
                              visible: label == 'Ingredient Detail' ? false : true,
                              child: Form(
                                key: _formKey2,
                                child: Theme(
                                  data: ThemeData(
                                    primaryColor: AppColors.dietJournalOrange,
                                    focusColor: AppColors.dietJournalOrange,
                                    fixTextFieldOutlineLabel: true,
                                  ),
                                  child: TextFormField(
                                    controller: addIngredientController,
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
                                      labelText: '$label',
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
                          ],
                        ),
                      ),
                      Visibility(
                        visible: label == 'Ingredient Name',
                        child: GestureDetector(
                          onTap: () {
                            if (this.mounted) {
                              setState(() {
                                int i = labels.indexOf('$label');
                                if (label == 'Dish Image' && imageSelected) {
                                  label = labels[i + 1];
                                } else {
                                  // calorieInIngredient;
                                  if (editing && _formKey2.currentState.validate()) {
                                    if (this.mounted) {
                                      setState(() {
                                        if (labels[i] == 'Ingredient Name') {
                                          indgredientName = addIngredientController.text;
                                        } else if (labels[i] == 'Notes') {
                                          // notesForDish = addIngredientController.text;
                                          // if (ingredientsForDish.length >= 1) {
                                          //   calorieInDish = (int.tryParse(
                                          //               ingredientDetailsFromApi[
                                          //                   'calorie']) *
                                          //           ingredientsForDish.length)
                                          //       .toString();
                                          // }
                                        }
                                        editing = false;
                                        addIngredientController.clear();
                                        print('if editing true');
                                        label = '';
                                      });
                                    }
                                  } else if (_formKey2.currentState.validate() && !editing) {
                                    print('else if editing false');

                                    if (labels[i] == 'Ingredient Name') {
                                      indgredientName = addIngredientController.text;
                                    } else if (labels[i] == 'Notes') {
                                      // notesForDish = addNewDishController.text;
                                      // if (ingredientsForDish.length >= 1) {
                                      //   calorieInDish = (int.tryParse(ingredientDetailsFromApi[
                                      //               'calories']) *
                                      //           ingredientsForDish.length)
                                      //       .toString();
                                      // }
                                    }

                                    // txt='';
                                    addIngredientController.clear();

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
                        visible: //false,
                            label == 'Ingredient Detail',
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
                                      if (label == 'Ingredient Detail' &&
                                          _formKey.currentState.validate()) {
                                        ingredientsForDish.add(_typeAheadController.text);
                                        //an api will call every time you add ingredients
                                        if (ingredientsForDish.length >= 1) {
                                          calorieInIngredient =
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
                visible: indgredientName != null,
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
                                edit('Ingredient Name');
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
                                  (indgredientName != null ? indgredientName : '').toUpperCase(),
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
                                                text: calorieInIngredient != null
                                                    ? '$calorieInIngredient '
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
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.food_bank_outlined,
                                          color: Colors.transparent,
                                        ), //.primaryAccentColor,),
                                        SizedBox(
                                          width: 5.0,
                                        ),
                                        RichText(
                                          text: TextSpan(
                                            children: [
                                              TextSpan(
                                                text: '', //'2000 ',
                                                style: TextStyle(
                                                    fontSize: 20.0,
                                                    fontWeight: FontWeight.bold,
                                                    color: AppColors.appTextColor),
                                              ),
                                              TextSpan(
                                                text: '', //"g",
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
                                    image: ingredientsCroppedFile != null
                                        ? FileImage(File(ingredientsCroppedFile.path))
                                        : NetworkImage(
                                            'https://cdn-a.william-reed.com/var/wrbm_gb_food_pharma/storage/images/publications/food-beverage-nutrition/foodnavigator.com/news/market-trends/meat-free-convenience-and-traceability-ehl-ingredients-reveals-2020-food-trends/10511260-1-eng-GB/Meat-free-convenience-and-traceability-EHL-Ingredients-reveals-2020-food-trends_wrbm_large.jpg',
                                            // 'https://static.toiimg.com/thumb/msid-69095698,imgsize-186609,width-800,height-600,resizemode-75/69095698.jpg',
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

              Visibility(
                visible: true,
                child: GestureDetector(
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    color: Colors.white, //AppColors.cardColor,//Colors.white,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        ListTile(
                          title: Visibility(
                            visible: indgredientName != null,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                indgredientName != null ? indgredientName : '',
                                style: TextStyle(
                                    letterSpacing: 0.7,
                                    wordSpacing: 1.5,
                                    color: AppColors.textitemTitleColor, //primaryAccentColor,
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold),
                                // textAlign: TextAlign.justify,
                              ),
                            ),
                          ),
                          subtitle: Visibility(
                            visible: calorieInIngredient != null,
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 5,
                                ),
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
                                        text: calorieInIngredient != null
                                            ? '$calorieInIngredient '
                                            : '',
                                        style: TextStyle(
                                            fontSize: 20.0,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.appTextColor),
                                      ),
                                      TextSpan(
                                        text: "Cal ",
                                        style: TextStyle(
                                            color: AppColors.appTextColor, fontSize: 14.0),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              //add button

              Visibility(
                visible: completed && !editing,
                child: GestureDetector(
                  child: Container(
                    height: 50,
                    margin: EdgeInsets.only(bottom: 15, top: 5, left: 4.5, right: 5.4),
                    decoration: BoxDecoration(
                      color: //Color(0xffe5cac2),//
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
                                  'Add Ingredient',
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

  var ingredientDetailsFromApi = {}; //{'Protien':'3 % ', 'Fat':'4 %','Carbs':'7 %'};

  void edit(String dishLabel) {
    if (this.mounted) {
      setState(() {
        label = dishLabel;
        if (label == 'Dish Name') {
          addIngredientController.text = indgredientName;
        } else if (label == 'Notes') {
          // addIngredientController.text = notesForDish;
        }
      });
    }
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
    http.Client _client = http.Client(); //3gb
    List<String> matches = <String>[];
    matches.addAll(food);
    var match = [];
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // var data = prefs.get('data');
    // // var apiToken = prefs.get('auth_token');
    // Map res = jsonDecode(data);
    // var iHLUserId = res['User']['id'];
    if (false == true) {
      final response = await _client.get(
        Uri.parse(API.iHLUrl +
            "/consult/list_of_ingredient_starts_with?search_string=$query&ihl_user_id=abc"),
        headers: {
          'Content-Type': 'application/json',
          'ApiToken': '${API.headerr['ApiToken']}',
          'Token': '${API.headerr['Token']}',
        },
      );

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

/////////////////////////////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

// // import 'package:customgauge/customgauge.dart';
// import 'package:expandable/expandable.dart';
// import 'package:flutter/material.dart';
// import 'package:ihl/views/dietJournal/DietJournalUI.dart';
// import 'package:ihl/views/dietJournal/dietJournal.dart';
// // import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// // import 'package:ihl/utils/app_colors.dart';
// import 'package:ihl/views/home_screen.dart';
// import 'package:ihl/widgets/BasicPageUI.dart';
// import 'package:ihl/utils/ScUtil.dart';
// import 'package:ihl/utils/app_colors.dart';
// // import 'package:pdf/widgets.dart';
// import 'package:percent_indicator/circular_percent_indicator.dart';
// import 'package:flutter_typeahead/flutter_typeahead.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'add_new_dish.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;

// import 'food_details.dart';

// class AddIngredient extends StatefulWidget {
//   @override
//   _AddIngredientState createState() => _AddIngredientState();
// }

// class _AddIngredientState extends State<AddIngredient> {
//   @override
//     List labels = [
//     'Ingredient Name',
//     // 'Dish Image',
//     'Indgredient Details',
//     // 'Notes',
//     // 'Ideal Time'
//   ];
//   String label ='Ingredient Name';
//   bool imageSelected = false;
//   File ingredientsCroppedFile;
//   File _image;
//   String base64Image;
//   final picker = ImagePicker();
//   bool isLoading = false;
//   String ingredientName;
//   var ingredientDetails = {};
//   bool quantity = false;

//   final addNewIngredientController = TextEditingController();
//   final proteinController = TextEditingController();
//   final carbsController = TextEditingController();

//   final fatController = TextEditingController();
//   final vitamin_aController = TextEditingController();
//   final vitamin_cController = TextEditingController();
//   final sugarController = TextEditingController();
//   final sodiumController = TextEditingController();
//   final calciumController = TextEditingController();
//   final potasiumController = TextEditingController();
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//   void initState() {
//     super.initState();
//   }

//   Widget build(BuildContext context) {
//     return DietJournalUI(
//       appBar: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.only(bottom: 10.0),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 IconButton(
//                   icon: Icon(Icons.arrow_back_ios),
//                   onPressed: () => Navigator.of(context).pop(),
//                   // Navigator.pushAndRemoveUntil(
//                   //     context,
//                   //     MaterialPageRoute(builder: (context) => DietJournal()),
//                   //     // (introDone: true)),
//                   //     (Route<dynamic> route) => false),
//                   color: Colors.white,
//                   tooltip: 'Back',
//                 ),
//                 // Flexible(
//                 //   child: Center(
//                 //     child: Text(
//                 //       'Favourite Meal',
//                 //       style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
//                 //       textAlign: TextAlign.center,
//                 //     ),
//                 //   ),
//                 // ),
//                 Text(
//                   'Add Ingredient',
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: ScUtil().setSp(22),
//                     color: Colors.white,
//                   ),
//                 ),
//                 SizedBox(
//                   width: 40,
//                 )
//               ],
//             ),
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         child: Container(
//           margin: EdgeInsets.all(30),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               children: [
//                 TextFormField(
//                   controller: addNewIngredientController,
//                   validator: (v) {
//                     if (v.isEmpty) {
//                       return 'Please enter something!';
//                     }
//                     return null;
//                   },
//                   decoration: InputDecoration(
//                     contentPadding:
//                         EdgeInsets.symmetric(vertical: 18.0, horizontal: 15.0),
//                     prefixIcon: Padding(
//                       padding: const EdgeInsetsDirectional.only(end: 8.0),
//                       child: Icon(Icons.all_inbox),
//                     ),
//                     labelText: 'Ingredients Name',
//                     fillColor: Colors.white,
//                     border: new OutlineInputBorder(
//                         borderRadius: new BorderRadius.circular(15.0),
//                         borderSide: new BorderSide(color: Colors.blueGrey)),
//                   ),
//                   maxLines: 1,
//                   style: TextStyle(fontSize: 16.0),
//                   textInputAction: TextInputAction.done,
//                 ),
//                 SizedBox(height: 10),
//                 TextFormField(
//                   controller: proteinController,
//                   validator: (v) {
//                     if (v.isEmpty) {
//                       return 'Please enter something!';
//                     }
//                     return null;
//                   },
//                   decoration: InputDecoration(
//                     contentPadding:
//                         EdgeInsets.symmetric(vertical: 18.0, horizontal: 15.0),
//                     prefixIcon: Padding(
//                       padding: const EdgeInsetsDirectional.only(end: 8.0),
//                       child: Icon(Icons.all_inbox),
//                     ),
//                     labelText: 'Protein',
//                     fillColor: Colors.white,
//                     border: new OutlineInputBorder(
//                         borderRadius: new BorderRadius.circular(15.0),
//                         borderSide: new BorderSide(color: Colors.blueGrey)),
//                   ),
//                   maxLines: 1,
//                   style: TextStyle(fontSize: 16.0),
//                   textInputAction: TextInputAction.done,
//                 ),
//                 SizedBox(height: 10),
//                 TextFormField(
//                   controller: carbsController,
//                   validator: (v) {
//                     if (v.isEmpty) {
//                       return 'Please enter something!';
//                     }
//                     return null;
//                   },
//                   decoration: InputDecoration(
//                     contentPadding:
//                         EdgeInsets.symmetric(vertical: 18.0, horizontal: 15.0),
//                     prefixIcon: Padding(
//                       padding: const EdgeInsetsDirectional.only(end: 8.0),
//                       child: Icon(Icons.all_inbox),
//                     ),
//                     labelText: 'Carbs',
//                     fillColor: Colors.white,
//                     border: new OutlineInputBorder(
//                         borderRadius: new BorderRadius.circular(15.0),
//                         borderSide: new BorderSide(color: Colors.blueGrey)),
//                   ),
//                   maxLines: 1,
//                   style: TextStyle(fontSize: 16.0),
//                   textInputAction: TextInputAction.done,
//                 ),
//                 SizedBox(height: 10),
//                 TextFormField(
//                   controller: fatController,
//                   validator: (v) {
//                     if (v.isEmpty) {
//                       return 'Please enter something!';
//                     }
//                     return null;
//                   },
//                   decoration: InputDecoration(
//                     contentPadding:
//                         EdgeInsets.symmetric(vertical: 18.0, horizontal: 15.0),
//                     prefixIcon: Padding(
//                       padding: const EdgeInsetsDirectional.only(end: 8.0),
//                       child: Icon(Icons.all_inbox),
//                     ),
//                     labelText: 'Fat',
//                     fillColor: Colors.white,
//                     border: new OutlineInputBorder(
//                         borderRadius: new BorderRadius.circular(15.0),
//                         borderSide: new BorderSide(color: Colors.blueGrey)),
//                   ),
//                   maxLines: 1,
//                   style: TextStyle(fontSize: 16.0),
//                   textInputAction: TextInputAction.done,
//                 ),
//                 SizedBox(height: 10),
//                 TextFormField(
//                   controller: vitamin_aController,
//                   validator: (v) {
//                     if (v.isEmpty) {
//                       return 'Please enter something!';
//                     }
//                     return null;
//                   },
//                   decoration: InputDecoration(
//                     contentPadding:
//                         EdgeInsets.symmetric(vertical: 18.0, horizontal: 15.0),
//                     prefixIcon: Padding(
//                       padding: const EdgeInsetsDirectional.only(end: 8.0),
//                       child: Icon(Icons.all_inbox),
//                     ),
//                     labelText: 'vitamin_a',
//                     fillColor: Colors.white,
//                     border: new OutlineInputBorder(
//                         borderRadius: new BorderRadius.circular(15.0),
//                         borderSide: new BorderSide(color: Colors.blueGrey)),
//                   ),
//                   maxLines: 1,
//                   style: TextStyle(fontSize: 16.0),
//                   textInputAction: TextInputAction.done,
//                 ),
//                 SizedBox(height: 10),
//                 TextFormField(
//                   controller: vitamin_cController,
//                   validator: (v) {
//                     if (v.isEmpty) {
//                       return 'Please enter something!';
//                     }
//                     return null;
//                   },
//                   decoration: InputDecoration(
//                     contentPadding:
//                         EdgeInsets.symmetric(vertical: 18.0, horizontal: 15.0),
//                     prefixIcon: Padding(
//                       padding: const EdgeInsetsDirectional.only(end: 8.0),
//                       child: Icon(Icons.all_inbox),
//                     ),
//                     labelText: 'vitamin_c',
//                     fillColor: Colors.white,
//                     border: new OutlineInputBorder(
//                         borderRadius: new BorderRadius.circular(15.0),
//                         borderSide: new BorderSide(color: Colors.blueGrey)),
//                   ),
//                   maxLines: 1,
//                   style: TextStyle(fontSize: 16.0),
//                   textInputAction: TextInputAction.done,
//                 ),
//                 SizedBox(height: 10),
//                 TextFormField(
//                   controller: sugarController,
//                   validator: (v) {
//                     if (v.isEmpty) {
//                       return 'Please enter something!';
//                     }
//                     return null;
//                   },
//                   decoration: InputDecoration(
//                     contentPadding:
//                         EdgeInsets.symmetric(vertical: 18.0, horizontal: 15.0),
//                     prefixIcon: Padding(
//                       padding: const EdgeInsetsDirectional.only(end: 8.0),
//                       child: Icon(Icons.all_inbox),
//                     ),
//                     labelText: 'Sugar',
//                     fillColor: Colors.white,
//                     border: new OutlineInputBorder(
//                         borderRadius: new BorderRadius.circular(15.0),
//                         borderSide: new BorderSide(color: Colors.blueGrey)),
//                   ),
//                   maxLines: 1,
//                   style: TextStyle(fontSize: 16.0),
//                   textInputAction: TextInputAction.done,
//                 ),
//                 SizedBox(height: 10),
//                 TextFormField(
//                   controller: sodiumController,
//                   validator: (v) {
//                     if (v.isEmpty) {
//                       return 'Please enter something!';
//                     }
//                     return null;
//                   },
//                   decoration: InputDecoration(
//                     contentPadding:
//                         EdgeInsets.symmetric(vertical: 18.0, horizontal: 15.0),
//                     prefixIcon: Padding(
//                       padding: const EdgeInsetsDirectional.only(end: 8.0),
//                       child: Icon(Icons.all_inbox),
//                     ),
//                     labelText: 'Sodium',
//                     fillColor: Colors.white,
//                     border: new OutlineInputBorder(
//                         borderRadius: new BorderRadius.circular(15.0),
//                         borderSide: new BorderSide(color: Colors.blueGrey)),
//                   ),
//                   maxLines: 1,
//                   style: TextStyle(fontSize: 16.0),
//                   textInputAction: TextInputAction.done,
//                 ),
//                 SizedBox(height: 10),
//                 TextFormField(
//                   controller: calciumController,
//                   validator: (v) {
//                     if (v.isEmpty) {
//                       return 'Please enter something!';
//                     }
//                     return null;
//                   },
//                   decoration: InputDecoration(
//                     contentPadding:
//                         EdgeInsets.symmetric(vertical: 18.0, horizontal: 15.0),
//                     prefixIcon: Padding(
//                       padding: const EdgeInsetsDirectional.only(end: 8.0),
//                       child: Icon(Icons.all_inbox),
//                     ),
//                     labelText: 'Calcium',
//                     fillColor: Colors.white,
//                     border: new OutlineInputBorder(
//                         borderRadius: new BorderRadius.circular(15.0),
//                         borderSide: new BorderSide(color: Colors.blueGrey)),
//                   ),
//                   maxLines: 1,
//                   style: TextStyle(fontSize: 16.0),
//                   textInputAction: TextInputAction.done,
//                 ),
//                 SizedBox(height: 10),
//                 TextFormField(
//                   controller: potasiumController,
//                   validator: (v) {
//                     if (v.isEmpty) {
//                       return 'Please enter something!';
//                     }
//                     return null;
//                   },
//                   decoration: InputDecoration(
//                     contentPadding:
//                         EdgeInsets.symmetric(vertical: 18.0, horizontal: 15.0),
//                     prefixIcon: Padding(
//                       padding: const EdgeInsetsDirectional.only(end: 8.0),
//                       child: Icon(Icons.all_inbox),
//                     ),
//                     labelText: 'Potasium',
//                     fillColor: Colors.white,
//                     border: new OutlineInputBorder(
//                         borderRadius: new BorderRadius.circular(15.0),
//                         borderSide: new BorderSide(color: Colors.blueGrey)),
//                   ),
//                   maxLines: 1,
//                   style: TextStyle(fontSize: 16.0),
//                   textInputAction: TextInputAction.done,
//                 ),
//                 SizedBox(height: 10),
//                 GestureDetector(
//                   onTap: () {
//                     if (_formKey.currentState.validate()) {
//                       Navigator.of(context).pop();
//                     }
//                   },
//                   child: Container(
//                     height: 50,
//                     margin: EdgeInsets.only(
//                         bottom: 15, top: 0, left: 0, right: 5.4),
//                     decoration: BoxDecoration(
//                       color: AppColors.dietJournalOrange,
//                       borderRadius: BorderRadius.circular(20.0),
//                     ),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: <Widget>[
//                         Center(
//                           child:
//                               //  isLoading == true
//                               //     ? new CircularProgressIndicator(
//                               //         valueColor:
//                               //             AlwaysStoppedAnimation<Color>(Colors.white),
//                               //       )
//                               //     :
//                               Text(
//                             'Add Ingredient',
//                             textAlign: TextAlign.center,
//                             style: TextStyle(
//                                 color: Color.fromRGBO(255, 255, 255, 1),
//                                 fontFamily: 'Poppins',
//                                 fontSize: ScUtil().setSp(16),
//                                 letterSpacing: 0.2,
//                                 fontWeight: FontWeight.normal,
//                                 height: 1),
//                           ),
//                         )
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
