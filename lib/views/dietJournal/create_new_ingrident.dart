import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:ihl/views/dietJournal/DietJournalUI.dart';
import 'package:ihl/views/dietJournal/apis/log_apis.dart';
import 'package:ihl/views/dietJournal/models/create_edit_ingredient_model.dart';
import 'package:ihl/views/dietJournal/models/viewIngredientDetails_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:strings/strings.dart';

class CreateNewIngridientScreen extends StatefulWidget {
  final ListCustomIngredient customUserIngredient;
  final baseColor;
  const CreateNewIngridientScreen({this.customUserIngredient, this.baseColor});
  @override
  _CreateNewIngridientScreenState createState() => _CreateNewIngridientScreenState();
}

class _CreateNewIngridientScreenState extends State<CreateNewIngridientScreen> {
  bool submitted = false;
  final _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  TextEditingController nameController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController quantityTypeController = TextEditingController();
  TextEditingController calorieController = TextEditingController();
  TextEditingController protienController = TextEditingController();
  TextEditingController carbController = TextEditingController();
  TextEditingController fiberController = TextEditingController();
  TextEditingController sugarController = TextEditingController();
  TextEditingController satFatController = TextEditingController();
  TextEditingController monoFatController = TextEditingController();
  TextEditingController polyFatController = TextEditingController();
  TextEditingController transFatController = TextEditingController();
  TextEditingController cholestrolController = TextEditingController();
  TextEditingController sodiumController = TextEditingController();
  TextEditingController potassiumController = TextEditingController();
  TextEditingController calciumController = TextEditingController();
  TextEditingController ironController = TextEditingController();
  TextEditingController vitaminAController = TextEditingController();
  TextEditingController vitaminCController = TextEditingController();
  TextEditingController notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getDetails();
  }

  void getDetails() async {
    if (widget.customUserIngredient != null) {
      if (this.mounted) {
        setState(() {
          nameController.text = widget.customUserIngredient.item;
          quantityController.text = widget.customUserIngredient.amount;
          quantityTypeController.text = widget.customUserIngredient.amountUnit;
          calorieController.text = widget.customUserIngredient.calories;
          protienController.text = widget.customUserIngredient.protiens;
          carbController.text = widget.customUserIngredient.totalCarbohydrate;
          fiberController.text = widget.customUserIngredient.fiber;
          sugarController.text = widget.customUserIngredient.sugar;
          satFatController.text = widget.customUserIngredient.saturatedFat;
          monoFatController.text = widget.customUserIngredient.monounsaturatedFats;
          polyFatController.text = widget.customUserIngredient.polyunsaturatedFats;
          transFatController.text = widget.customUserIngredient.transfattyAcid;
          cholestrolController.text = widget.customUserIngredient.colesterol;
          sodiumController.text = widget.customUserIngredient.sodium;
          potassiumController.text = widget.customUserIngredient.potassium;
          calciumController.text = widget.customUserIngredient.calcium;
          ironController.text = '';
          vitaminAController.text = widget.customUserIngredient.vitaminA;
          vitaminCController.text = widget.customUserIngredient.vitaminC;
          notesController.text = widget.customUserIngredient.notes;
        });
      }
    }
  }

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
            if (_formKey.currentState.validate()) {
              createCustomFood();
            } else {
              if (this.mounted) {
                setState(() {
                  _autoValidate = true;
                });
              }
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

  void createCustomFood() async {
    if (this.mounted) {
      setState(() {
        submitted = true;
      });
    }
    final prefs = await SharedPreferences.getInstance();
    String iHLUserId = prefs.getString('ihlUserId');
    CreateEditIngredient logFood = CreateEditIngredient(
        ihlId: iHLUserId,
        calories: calorieController.text,
        carbs: carbController.text,
        fats: satFatController.text,
        fiber: fiberController.text,
        ingredient: nameController.text,
        protein: protienController.text,
        quantity: quantityController.text,
        servingUnitSize: quantityTypeController.text,
        foodId: ''

        // ihlId: iHLUserId,
        // additionalRegion: '',
        // userIngredientId1: '',
        // quanity: quantityController.text,
        // calcium: calciumController.text,
        // colesterol: cholestrolController.text,
        // fiber: fiberController.text,
        // item: nameController.text,
        // ingredients: '',
        // monounsaturatedFats: monoFatController.text,
        // polyunsaturatedFats: polyFatController.text,
        // potassium: potassiumController.text,
        // preference: '',
        // iron: ironController.text,
        // protiens: protienController.text,
        // amountUnit: quantityTypeController.text,
        // quantityUnit: quantityTypeController.text,
        // restrictedFor: '',
        // calories: calorieController.text,
        // saturatedFat: satFatController.text,
        // sodium: sodiumController.text,
        // sugar: sugarController.text,
        // timingsFor: '',
        // totalCarbohydrate: carbController.text,
        // totalFat: satFatController.text,
        // transfattyAcid: transFatController.text,
        // vitaminA: vitaminAController.text,
        // notes: notesController.text,
        // vitaminC: vitaminCController.text,
        );
    LogApis.createEditCustomIngredientApi(data: logFood).then((value) {
      if (value != null) {
        if (this.mounted) {
          setState(() {
            submitted = false;
          });
        }
        Get.close(1);
        Get.snackbar('Created!', '${camelize(nameController.text)} created successfully.',
            icon: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(Icons.check_circle, color: Colors.white)),
            margin: EdgeInsets.all(20).copyWith(bottom: 40),
            backgroundColor: AppColors.primaryAccentColor,
            colorText: Colors.white,
            duration: Duration(seconds: 5),
            snackPosition: SnackPosition.BOTTOM);
      } else {
        //Get.close(1);
        Get.snackbar(
            'Ingredient not created!', 'Encountered some error while creating. Please try again',
            icon: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(Icons.check_circle, color: Colors.white)),
            margin: EdgeInsets.all(20).copyWith(bottom: 40),
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: Duration(seconds: 5),
            snackPosition: SnackPosition.BOTTOM);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DietJournalUI(
      appBar: AppBar(
        backgroundColor: widget.baseColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Create New Ingredient',
          style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w500, color: Colors.white),
          // style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
          maxLines: 1,
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);

          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
          // if (_formKey.currentState.validate()) {
          // } else {
          //   if (this.mounted) {
          //     setState(() {
          //       _autoValidate = true;
          //     });
          //   }
          // }
        },
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
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
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 20),
                        Text(
                          'Title of the Ingredient',
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
                        TextFormField(
                          controller: nameController,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Ingredient title can\'t be empty!';
                            } else if (value.length < 3 && value.isNotEmpty) {
                              return "Atleast 3 characters needed.";
                            } else if (value.contains(RegExp(r'[0-9]'))) {
                              return 'Ingredient title can\'t be numbers!';
                            } else if (value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
                              return 'Ingredient title can\'t be special characters!';
                            } else if ((value.length > 100) && value.isNotEmpty) {
                              return "Ingridient name should be less than 100 chars";
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(vertical: 18.0, horizontal: 15.0),
                            labelText: "Ingredient Title",
                            counterText: "",
                            counterStyle: TextStyle(fontSize: 0),
                            fillColor: Colors.white,
                            border: new OutlineInputBorder(
                                borderRadius: new BorderRadius.circular(15.0),
                                borderSide: new BorderSide(color: Colors.blueGrey)),
                          ),
                          style: TextStyle(
                            fontSize: 16,
                          ),
                          inputFormatters: [
                            // FilteringTextInputFormatter.allow(
                            //     RegExp("[a-zA-Z]"))
                          ],
                          textInputAction: TextInputAction.next,
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Ingredient Amount',
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
                        TextFormField(
                          controller: quantityController,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Amount can\'t be empty!';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(vertical: 18.0, horizontal: 15.0),
                            labelText: "Amount",
                            counterText: "",
                            counterStyle: TextStyle(fontSize: 0),
                            fillColor: Colors.white,
                            border: new OutlineInputBorder(
                                borderRadius: new BorderRadius.circular(15.0),
                                borderSide: new BorderSide(color: Colors.blueGrey)),
                          ),
                          style: TextStyle(
                            fontSize: 16,
                          ),
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Amount Unit',
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
                        TextFormField(
                          controller: quantityTypeController,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Amount Unit can\'t be empty!';
                            } else if (value.length < 2 && value.isNotEmpty) {
                              return "Atleast 2 characters needed.";
                            } else if ((value.length > 10) && value.isNotEmpty) {
                              return "Amount Unit should be less than 10 chars";
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(vertical: 18.0, horizontal: 15.0),
                            labelText: "Amount Unit",
                            counterText: "",
                            counterStyle: TextStyle(fontSize: 0),
                            fillColor: Colors.white,
                            border: new OutlineInputBorder(
                                borderRadius: new BorderRadius.circular(15.0),
                                borderSide: new BorderSide(color: Colors.blueGrey)),
                          ),
                          style: TextStyle(
                            fontSize: 16,
                          ),
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp("[a-zA-Z]"))],
                          textInputAction: TextInputAction.next,
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Calories of the Ingredient',
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
                        TextFormField(
                          controller: calorieController,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Calories can\'t be empty!';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(vertical: 18.0, horizontal: 15.0),
                            labelText: "Calories",
                            counterText: "",
                            counterStyle: TextStyle(fontSize: 0),
                            fillColor: Colors.white,
                            border: new OutlineInputBorder(
                                borderRadius: new BorderRadius.circular(15.0),
                                borderSide: new BorderSide(color: Colors.blueGrey)),
                          ),
                          style: TextStyle(
                            fontSize: 16,
                          ),
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.number,
                        ),
                        SizedBox(height: 20),
                        Row(
                          children: [
                            Text(
                              'Protien (in grams)',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontFamily: FitnessAppTheme.fontName,
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                                letterSpacing: 0.5,
                                color: AppColors.textitemTitleColor,
                              ),
                            ),
                            SizedBox(width: 20),
                            Expanded(
                              child: TextFormField(
                                controller: protienController,
                                decoration: InputDecoration(
                                  contentPadding:
                                      EdgeInsets.symmetric(vertical: 18.0, horizontal: 15.0),
                                  labelText: "Protien",
                                  suffixText: 'gms',
                                  counterText: "",
                                  counterStyle: TextStyle(fontSize: 0),
                                  fillColor: Colors.white,
                                  border: new OutlineInputBorder(
                                      borderRadius: new BorderRadius.circular(15.0),
                                      borderSide: new BorderSide(color: Colors.blueGrey)),
                                ),
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                textInputAction: TextInputAction.next,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Row(
                          children: [
                            Text(
                              'Carbohydrates\n(in grams)',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontFamily: FitnessAppTheme.fontName,
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                                letterSpacing: 0.5,
                                color: AppColors.textitemTitleColor,
                              ),
                            ),
                            SizedBox(width: 20),
                            Expanded(
                              child: TextFormField(
                                controller: carbController,
                                decoration: InputDecoration(
                                  contentPadding:
                                      EdgeInsets.symmetric(vertical: 18.0, horizontal: 15.0),
                                  labelText: "Carbs.",
                                  suffixText: 'gms',
                                  counterText: "",
                                  counterStyle: TextStyle(fontSize: 0),
                                  fillColor: Colors.white,
                                  border: new OutlineInputBorder(
                                      borderRadius: new BorderRadius.circular(15.0),
                                      borderSide: new BorderSide(color: Colors.blueGrey)),
                                ),
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                textInputAction: TextInputAction.next,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Row(
                          children: [
                            Text(
                              'Fibers (in grams)',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontFamily: FitnessAppTheme.fontName,
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                                letterSpacing: 0.5,
                                color: AppColors.textitemTitleColor,
                              ),
                            ),
                            SizedBox(width: 20),
                            Expanded(
                              child: TextFormField(
                                controller: fiberController,
                                decoration: InputDecoration(
                                  contentPadding:
                                      EdgeInsets.symmetric(vertical: 18.0, horizontal: 15.0),
                                  labelText: "Fiber",
                                  suffixText: 'gms',
                                  counterText: "",
                                  counterStyle: TextStyle(fontSize: 0),
                                  fillColor: Colors.white,
                                  border: new OutlineInputBorder(
                                      borderRadius: new BorderRadius.circular(15.0),
                                      borderSide: new BorderSide(color: Colors.blueGrey)),
                                ),
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                textInputAction: TextInputAction.next,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                        // SizedBox(height: 20),
                        // Row(
                        //   children: [
                        //     Text(
                        //       'Sugar (in grams)',
                        //       textAlign: TextAlign.left,
                        //       style: TextStyle(
                        //         fontFamily: FitnessAppTheme.fontName,
                        //         fontWeight: FontWeight.w600,
                        //         fontSize: 18,
                        //         letterSpacing: 0.5,
                        //         color: AppColors.textitemTitleColor,
                        //       ),
                        //     ),
                        //     SizedBox(width: 20),
                        //     Expanded(
                        //       child: TextFormField(
                        //         controller: sugarController,
                        //         decoration: InputDecoration(
                        //           contentPadding: EdgeInsets.symmetric(
                        //               vertical: 18.0, horizontal: 15.0),
                        //           labelText: "Sugar",
                        //           suffixText: 'gms',
                        //           counterText: "",
                        //           counterStyle: TextStyle(fontSize: 0),
                        //           fillColor: Colors.white,
                        //           border: new OutlineInputBorder(
                        //               borderRadius:
                        //                   new BorderRadius.circular(15.0),
                        //               borderSide: new BorderSide(
                        //                   color: Colors.blueGrey)),
                        //         ),
                        //         style: TextStyle(
                        //           fontSize: 16,
                        //         ),
                        //         inputFormatters: [
                        //           FilteringTextInputFormatter.digitsOnly
                        //         ],
                        //         textInputAction: TextInputAction.next,
                        //         keyboardType: TextInputType.number,
                        //       ),
                        //     ),
                        //   ],
                        // ),
                        SizedBox(height: 20),
                        Row(
                          children: [
                            Text(
                              'Saturated Fats\n(in grams)',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontFamily: FitnessAppTheme.fontName,
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                                letterSpacing: 0.5,
                                color: AppColors.textitemTitleColor,
                              ),
                            ),
                            SizedBox(width: 20),
                            Expanded(
                              child: TextFormField(
                                controller: satFatController,
                                decoration: InputDecoration(
                                  contentPadding:
                                      EdgeInsets.symmetric(vertical: 18.0, horizontal: 15.0),
                                  labelText: "Satur. fats",
                                  suffixText: 'gms',
                                  counterText: "",
                                  counterStyle: TextStyle(fontSize: 0),
                                  fillColor: Colors.white,
                                  border: new OutlineInputBorder(
                                      borderRadius: new BorderRadius.circular(15.0),
                                      borderSide: new BorderSide(color: Colors.blueGrey)),
                                ),
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                textInputAction: TextInputAction.next,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        // Row(
                        //   children: [
                        //     Text(
                        //       'Mono Unsaturated\nFats (in grams)',
                        //       textAlign: TextAlign.left,
                        //       style: TextStyle(
                        //         fontFamily: FitnessAppTheme.fontName,
                        //         fontWeight: FontWeight.w600,
                        //         fontSize: 18,
                        //         letterSpacing: 0.5,
                        //         color: AppColors.textitemTitleColor,
                        //       ),
                        //     ),
                        //     SizedBox(width: 20),
                        //     Expanded(
                        //       child: TextFormField(
                        //         controller: monoFatController,
                        //         decoration: InputDecoration(
                        //           contentPadding: EdgeInsets.symmetric(
                        //               vertical: 18.0, horizontal: 15.0),
                        //           labelText: "Mono Unsatur. fats",
                        //           suffixText: 'gms',
                        //           counterText: "",
                        //           counterStyle: TextStyle(fontSize: 0),
                        //           fillColor: Colors.white,
                        //           border: new OutlineInputBorder(
                        //               borderRadius:
                        //                   new BorderRadius.circular(15.0),
                        //               borderSide: new BorderSide(
                        //                   color: Colors.blueGrey)),
                        //         ),
                        //         style: TextStyle(
                        //           fontSize: 16,
                        //         ),
                        //         inputFormatters: [
                        //           FilteringTextInputFormatter.digitsOnly
                        //         ],
                        //         textInputAction: TextInputAction.next,
                        //         keyboardType: TextInputType.number,
                        //       ),
                        //     ),
                        //   ],
                        // ),
                        // SizedBox(height: 20),
                        // Row(
                        //   children: [
                        //     Text(
                        //       'Poly Unsaturated\nFats (in grams)',
                        //       textAlign: TextAlign.left,
                        //       style: TextStyle(
                        //         fontFamily: FitnessAppTheme.fontName,
                        //         fontWeight: FontWeight.w600,
                        //         fontSize: 18,
                        //         letterSpacing: 0.5,
                        //         color: AppColors.textitemTitleColor,
                        //       ),
                        //     ),
                        //     SizedBox(width: 20),
                        //     Expanded(
                        //       child: TextFormField(
                        //         controller: polyFatController,
                        //         decoration: InputDecoration(
                        //           contentPadding: EdgeInsets.symmetric(
                        //               vertical: 18.0, horizontal: 15.0),
                        //           labelText: "Satur. fats",
                        //           suffixText: 'gms',
                        //           counterText: "",
                        //           counterStyle: TextStyle(fontSize: 0),
                        //           fillColor: Colors.white,
                        //           border: new OutlineInputBorder(
                        //               borderRadius:
                        //                   new BorderRadius.circular(15.0),
                        //               borderSide: new BorderSide(
                        //                   color: Colors.blueGrey)),
                        //         ),
                        //         style: TextStyle(
                        //           fontSize: 16,
                        //         ),
                        //         inputFormatters: [
                        //           FilteringTextInputFormatter.digitsOnly
                        //         ],
                        //         textInputAction: TextInputAction.next,
                        //         keyboardType: TextInputType.number,
                        //       ),
                        //     ),
                        //   ],
                        // ),
                        // SizedBox(height: 20),
                        // Row(
                        //   children: [
                        //     Text(
                        //       'Trans fatty Acid\n(in grams)',
                        //       textAlign: TextAlign.left,
                        //       style: TextStyle(
                        //         fontFamily: FitnessAppTheme.fontName,
                        //         fontWeight: FontWeight.w600,
                        //         fontSize: 18,
                        //         letterSpacing: 0.5,
                        //         color: AppColors.textitemTitleColor,
                        //       ),
                        //     ),
                        //     SizedBox(width: 20),
                        //     Expanded(
                        //       child: TextFormField(
                        //         controller: transFatController,
                        //         decoration: InputDecoration(
                        //           contentPadding: EdgeInsets.symmetric(
                        //               vertical: 18.0, horizontal: 15.0),
                        //           labelText: "Trans. fatty acid",
                        //           suffixText: 'gms',
                        //           counterText: "",
                        //           counterStyle: TextStyle(fontSize: 0),
                        //           fillColor: Colors.white,
                        //           border: new OutlineInputBorder(
                        //               borderRadius:
                        //                   new BorderRadius.circular(15.0),
                        //               borderSide: new BorderSide(
                        //                   color: Colors.blueGrey)),
                        //         ),
                        //         style: TextStyle(
                        //           fontSize: 16,
                        //         ),
                        //         inputFormatters: [
                        //           FilteringTextInputFormatter.digitsOnly
                        //         ],
                        //         textInputAction: TextInputAction.next,
                        //         keyboardType: TextInputType.number,
                        //       ),
                        //     ),
                        //   ],
                        // ),
                        // SizedBox(height: 20),
                        // Row(
                        //   children: [
                        //     Text(
                        //       'Cholesterol (in mg)',
                        //       textAlign: TextAlign.right,
                        //       style: TextStyle(
                        //         fontFamily: FitnessAppTheme.fontName,
                        //         fontWeight: FontWeight.w600,
                        //         fontSize: 18,
                        //         letterSpacing: 0.5,
                        //         color: AppColors.textitemTitleColor,
                        //       ),
                        //     ),
                        //     SizedBox(width: 20),
                        //     Expanded(
                        //       child: TextFormField(
                        //         controller: cholestrolController,
                        //         decoration: InputDecoration(
                        //           contentPadding: EdgeInsets.symmetric(
                        //               vertical: 18.0, horizontal: 15.0),
                        //           labelText: "Cholesterol",
                        //           suffixText: 'mg',
                        //           counterText: "",
                        //           counterStyle: TextStyle(fontSize: 0),
                        //           fillColor: Colors.white,
                        //           border: new OutlineInputBorder(
                        //               borderRadius:
                        //                   new BorderRadius.circular(15.0),
                        //               borderSide: new BorderSide(
                        //                   color: Colors.blueGrey)),
                        //         ),
                        //         style: TextStyle(
                        //           fontSize: 16,
                        //         ),
                        //         inputFormatters: [
                        //           FilteringTextInputFormatter.digitsOnly
                        //         ],
                        //         textInputAction: TextInputAction.next,
                        //         keyboardType: TextInputType.number,
                        //       ),
                        //     ),
                        //   ],
                        // ),
                        // SizedBox(height: 20),
                        // Row(
                        //   children: [
                        //     Text(
                        //       'Sodium (in mg)',
                        //       textAlign: TextAlign.right,
                        //       style: TextStyle(
                        //         fontFamily: FitnessAppTheme.fontName,
                        //         fontWeight: FontWeight.w600,
                        //         fontSize: 18,
                        //         letterSpacing: 0.5,
                        //         color: AppColors.textitemTitleColor,
                        //       ),
                        //     ),
                        //     SizedBox(width: 20),
                        //     Expanded(
                        //       child: TextFormField(
                        //         controller: sodiumController,
                        //         decoration: InputDecoration(
                        //           contentPadding: EdgeInsets.symmetric(
                        //               vertical: 18.0, horizontal: 15.0),
                        //           labelText: "Sodium",
                        //           suffixText: 'mg',
                        //           counterText: "",
                        //           counterStyle: TextStyle(fontSize: 0),
                        //           fillColor: Colors.white,
                        //           border: new OutlineInputBorder(
                        //               borderRadius:
                        //                   new BorderRadius.circular(15.0),
                        //               borderSide: new BorderSide(
                        //                   color: Colors.blueGrey)),
                        //         ),
                        //         style: TextStyle(
                        //           fontSize: 16,
                        //         ),
                        //         inputFormatters: [
                        //           FilteringTextInputFormatter.digitsOnly
                        //         ],
                        //         textInputAction: TextInputAction.next,
                        //         keyboardType: TextInputType.number,
                        //       ),
                        //     ),
                        //   ],
                        // ),
                        // SizedBox(height: 20),
                        // Row(
                        //   children: [
                        //     Text(
                        //       'Potassium (in mg)',
                        //       textAlign: TextAlign.right,
                        //       style: TextStyle(
                        //         fontFamily: FitnessAppTheme.fontName,
                        //         fontWeight: FontWeight.w600,
                        //         fontSize: 18,
                        //         letterSpacing: 0.5,
                        //         color: AppColors.textitemTitleColor,
                        //       ),
                        //     ),
                        //     SizedBox(width: 20),
                        //     Expanded(
                        //       child: TextFormField(
                        //         controller: potassiumController,
                        //         decoration: InputDecoration(
                        //           contentPadding: EdgeInsets.symmetric(
                        //               vertical: 18.0, horizontal: 15.0),
                        //           labelText: "Potassium",
                        //           suffixText: 'mg',
                        //           counterText: "",
                        //           counterStyle: TextStyle(fontSize: 0),
                        //           fillColor: Colors.white,
                        //           border: new OutlineInputBorder(
                        //               borderRadius:
                        //                   new BorderRadius.circular(15.0),
                        //               borderSide: new BorderSide(
                        //                   color: Colors.blueGrey)),
                        //         ),
                        //         style: TextStyle(
                        //           fontSize: 16,
                        //         ),
                        //         inputFormatters: [
                        //           FilteringTextInputFormatter.digitsOnly
                        //         ],
                        //         textInputAction: TextInputAction.next,
                        //         keyboardType: TextInputType.number,
                        //       ),
                        //     ),
                        //   ],
                        // ),
                        // SizedBox(height: 20),
                        // Row(
                        //   children: [
                        //     Text(
                        //       'Calcium (in %)',
                        //       textAlign: TextAlign.right,
                        //       style: TextStyle(
                        //         fontFamily: FitnessAppTheme.fontName,
                        //         fontWeight: FontWeight.w600,
                        //         fontSize: 18,
                        //         letterSpacing: 0.5,
                        //         color: AppColors.textitemTitleColor,
                        //       ),
                        //     ),
                        //     SizedBox(width: 20),
                        //     Expanded(
                        //       child: TextFormField(
                        //         controller: calciumController,
                        //         decoration: InputDecoration(
                        //           contentPadding: EdgeInsets.symmetric(
                        //               vertical: 18.0, horizontal: 15.0),
                        //           labelText: "Calcium",
                        //           suffixText: '%',
                        //           counterText: "",
                        //           counterStyle: TextStyle(fontSize: 0),
                        //           fillColor: Colors.white,
                        //           border: new OutlineInputBorder(
                        //               borderRadius:
                        //                   new BorderRadius.circular(15.0),
                        //               borderSide: new BorderSide(
                        //                   color: Colors.blueGrey)),
                        //         ),
                        //         maxLength: 2,
                        //         style: TextStyle(
                        //           fontSize: 16,
                        //         ),
                        //         inputFormatters: [
                        //           FilteringTextInputFormatter.digitsOnly
                        //         ],
                        //         textInputAction: TextInputAction.next,
                        //         keyboardType: TextInputType.number,
                        //       ),
                        //     ),
                        //   ],
                        // ),
                        // SizedBox(height: 20),
                        // Row(
                        //   children: [
                        //     Text(
                        //       'Iron (in %)',
                        //       textAlign: TextAlign.right,
                        //       style: TextStyle(
                        //         fontFamily: FitnessAppTheme.fontName,
                        //         fontWeight: FontWeight.w600,
                        //         fontSize: 18,
                        //         letterSpacing: 0.5,
                        //         color: AppColors.textitemTitleColor,
                        //       ),
                        //     ),
                        //     SizedBox(width: 20),
                        //     Expanded(
                        //       child: TextFormField(
                        //         controller: ironController,
                        //         decoration: InputDecoration(
                        //           contentPadding: EdgeInsets.symmetric(
                        //               vertical: 18.0, horizontal: 15.0),
                        //           labelText: "Iron",
                        //           suffixText: '%',
                        //           counterText: "",
                        //           counterStyle: TextStyle(fontSize: 0),
                        //           fillColor: Colors.white,
                        //           border: new OutlineInputBorder(
                        //               borderRadius:
                        //                   new BorderRadius.circular(15.0),
                        //               borderSide: new BorderSide(
                        //                   color: Colors.blueGrey)),
                        //         ),
                        //         maxLength: 2,
                        //         style: TextStyle(
                        //           fontSize: 16,
                        //         ),
                        //         inputFormatters: [
                        //           FilteringTextInputFormatter.digitsOnly
                        //         ],
                        //         textInputAction: TextInputAction.next,
                        //         keyboardType: TextInputType.number,
                        //       ),
                        //     ),
                        //   ],
                        // ),
                        // SizedBox(height: 20),
                        // Row(
                        //   children: [
                        //     Text(
                        //       'Vitamin A (in %)',
                        //       textAlign: TextAlign.right,
                        //       style: TextStyle(
                        //         fontFamily: FitnessAppTheme.fontName,
                        //         fontWeight: FontWeight.w600,
                        //         fontSize: 18,
                        //         letterSpacing: 0.5,
                        //         color: AppColors.textitemTitleColor,
                        //       ),
                        //     ),
                        //     SizedBox(width: 20),
                        //     Expanded(
                        //       child: TextFormField(
                        //         controller: vitaminAController,
                        //         decoration: InputDecoration(
                        //           contentPadding: EdgeInsets.symmetric(
                        //               vertical: 18.0, horizontal: 15.0),
                        //           labelText: "Vitamin A",
                        //           suffixText: '%',
                        //           counterText: "",
                        //           counterStyle: TextStyle(fontSize: 0),
                        //           fillColor: Colors.white,
                        //           border: new OutlineInputBorder(
                        //               borderRadius:
                        //                   new BorderRadius.circular(15.0),
                        //               borderSide: new BorderSide(
                        //                   color: Colors.blueGrey)),
                        //         ),
                        //         maxLength: 2,
                        //         style: TextStyle(
                        //           fontSize: 16,
                        //         ),
                        //         inputFormatters: [
                        //           FilteringTextInputFormatter.digitsOnly
                        //         ],
                        //         textInputAction: TextInputAction.next,
                        //         keyboardType: TextInputType.number,
                        //       ),
                        //     ),
                        //   ],
                        // ),
                        // SizedBox(height: 20),
                        // Row(
                        //   children: [
                        //     Text(
                        //       'Vitamin C (in %)',
                        //       textAlign: TextAlign.right,
                        //       style: TextStyle(
                        //         fontFamily: FitnessAppTheme.fontName,
                        //         fontWeight: FontWeight.w600,
                        //         fontSize: 18,
                        //         letterSpacing: 0.5,
                        //         color: AppColors.textitemTitleColor,
                        //       ),
                        //     ),
                        //     SizedBox(width: 20),
                        //     Expanded(
                        //       child: TextFormField(
                        //         controller: vitaminCController,
                        //         decoration: InputDecoration(
                        //           contentPadding: EdgeInsets.symmetric(
                        //               vertical: 18.0, horizontal: 15.0),
                        //           labelText: "Vitamin C",
                        //           suffixText: '%',
                        //           counterText: "",
                        //           counterStyle: TextStyle(fontSize: 0),
                        //           fillColor: Colors.white,
                        //           border: new OutlineInputBorder(
                        //               borderRadius:
                        //                   new BorderRadius.circular(15.0),
                        //               borderSide: new BorderSide(
                        //                   color: Colors.blueGrey)),
                        //         ),
                        //         style: TextStyle(
                        //           fontSize: 16,
                        //         ),
                        //         inputFormatters: [
                        //           FilteringTextInputFormatter.digitsOnly
                        //         ],
                        //         textInputAction: TextInputAction.next,
                        //         keyboardType: TextInputType.number,
                        //       ),
                        //     ),
                        //   ],
                        // ),
                        // SizedBox(height: 20),
                        // Row(
                        //   children: [
                        //     Text(
                        //       'Notes (optional)',
                        //       textAlign: TextAlign.right,
                        //       style: TextStyle(
                        //         fontFamily: FitnessAppTheme.fontName,
                        //         fontWeight: FontWeight.w600,
                        //         fontSize: 18,
                        //         letterSpacing: 0.5,
                        //         color: AppColors.textitemTitleColor,
                        //       ),
                        //     ),
                        //     SizedBox(width: 20),
                        //     Expanded(
                        //       child: TextFormField(
                        //         controller: notesController,
                        //         decoration: InputDecoration(
                        //           contentPadding: EdgeInsets.symmetric(
                        //               vertical: 18.0, horizontal: 15.0),
                        //           labelText: "Notes",
                        //           counterText: "",
                        //           counterStyle: TextStyle(fontSize: 0),
                        //           fillColor: Colors.white,
                        //           border: new OutlineInputBorder(
                        //               borderRadius:
                        //                   new BorderRadius.circular(15.0),
                        //               borderSide: new BorderSide(
                        //                   color: Colors.blueGrey)),
                        //         ),
                        //         style: TextStyle(
                        //           fontSize: 16,
                        //         ),
                        //         textInputAction: TextInputAction.done,
                        //       ),
                        //     ),
                        //   ],
                        // ),
                        // SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 50.0, right: 50.0),
                  child: Center(
                    child: _customButton(),
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
