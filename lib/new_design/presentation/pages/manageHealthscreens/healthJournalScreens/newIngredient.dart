import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ihl/new_design/presentation/pages/dashboard/common_screen_for_navigation.dart';
import 'package:ihl/utils/app_colors.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:strings/strings.dart';

import '../../../../../views/dietJournal/apis/log_apis.dart';
import '../../../../../views/dietJournal/models/create_edit_ingredient_model.dart';

class AddNewIngredient extends StatefulWidget {
  AddNewIngredient({
    Key key,
    @required this.baseColor,
    @required this.editMeal,
  }) : super(key: key);
  final baseColor;
  final bool editMeal;
  @override
  State<AddNewIngredient> createState() => _AddNewIngredientState();
}

class _AddNewIngredientState extends State<AddNewIngredient> {
  var demolist = [1, 2, 3, 4, 5, 6, 7, 8];
  double _kItemExtent = 32.0;
  var _selectedFruit = 8;
  TextEditingController nameController = TextEditingController();
  TextEditingController ingridientController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController quantityTypeController = TextEditingController();
  TextEditingController calorieController = TextEditingController();
  TextEditingController protienController = TextEditingController();
  TextEditingController carbController = TextEditingController();
  TextEditingController fiberController = TextEditingController();

  TextEditingController totalFatController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  void createCustomFood() async {
    // if (this.mounted) {
    //   setState(() {
    //     submitted = true;
    //   });
    // }
    final prefs = await SharedPreferences.getInstance();
    String iHLUserId = prefs.getString('ihlUserId');
    CreateEditIngredient logFood = CreateEditIngredient(
        ihlId: iHLUserId,
        calories: calorieController.text,
        carbs: carbController.text!=""?carbController.text:"0",
        fats: totalFatController.text!=""?totalFatController.text:"0",
        fiber: fiberController.text!=""?fiberController.text:"0",
        ingredient: ingridientController.text,
        protein: protienController.text!=""?protienController.text:"0",
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
        // if (this.mounted) {
        //   setState(() {
        //     submitted = false;
        //   });
        // }
        Get.close(1);
        Get.snackbar('Created!', '${camelize(nameController.text)} created successfully.',
            icon: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.check_circle, color: Colors.white)),
            margin: const EdgeInsets.all(20).copyWith(bottom: 40),
            backgroundColor: AppColors.primaryAccentColor,
            colorText: Colors.white,
            duration: const Duration(seconds: 5),
            snackPosition: SnackPosition.BOTTOM);
      } else {
        //Get.close(1);
        Get.snackbar(
            'Ingredient not created!', 'Encountered some error while creating. Please try again',
            icon: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.check_circle, color: Colors.white)),
            margin: const EdgeInsets.all(20).copyWith(bottom: 40),
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: const Duration(seconds: 5),
            snackPosition: SnackPosition.BOTTOM);
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
          title: const Text("Create New ingredient"),
          backgroundColor: widget.baseColor,
          centerTitle: true,
        ),
        content: Container(
          color: Colors.white,
          height: 100.h,
          padding: EdgeInsets.only(left: 4.w, right: 4.w),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 4.h,
                  ),
                  const Text('Title of ingredient'),
                  TextFormField(
                      enableInteractiveSelection: false,
                      controller: ingridientController,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) {
                        if (value.isEmpty || value.length >= 30) {
                          return "Enter Ingredient Name less than 30";
                        } else {
                          return null;
                        }
                      },
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        hintText: "Ingredient Title",
                        hintStyle: TextStyle(
                          color: Colors.grey.shade500,
                          fontStyle: FontStyle.normal,
                        ),
                      ),
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp("[a-zA-Z -]"))]),
                  SizedBox(
                    height: 3.h,
                  ),
                  const Text('Ingredient amount'),
                  TextFormField(
                    enableInteractiveSelection: false,
                    controller: quantityController,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    textInputAction: TextInputAction.next,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value.isEmpty) {
                        return "Ingredient shouldn't be empty";
                      } else {
                        num _v = num.tryParse(value);
                        if (_v != null) {
                          if (_v.isGreaterThan(2000) || _v <= 0) {
                            return 'Enter the quantity between 0 - 2000';
                          } else {
                            return null;
                          }
                        } else {
                          return "Enter valid quantity";
                        }
                      }
                    },
                    decoration: InputDecoration(
                      hintText: "Amount",
                      hintStyle: TextStyle(
                        color: Colors.grey.shade500,
                        fontStyle: FontStyle.normal,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 3.h,
                  ),
                  const Text('Amount unit'),
                  TextFormField(
                    enableInteractiveSelection: false,
                    textInputAction: TextInputAction.next,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    controller: quantityTypeController,
                    validator: (value) {
                      print(value);
                      if (value.isEmpty) {
                        return "Amount Unit shouldn't be empty";
                      } else if (value.length >= 10) {
                        return 'should not greater than 10';
                      } else if (RegExp(r'\d').hasMatch(value)) {
                        return 'should not contains numeric values';
                      } else {
                        return null;
                      }
                    },
                    decoration: InputDecoration(
                      hintText: "Amount Unit",
                      hintStyle: TextStyle(
                        color: Colors.grey.shade500,
                        fontStyle: FontStyle.normal,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 3.h,
                  ),
                  const Text('Calories of ingredient'),
                  TextFormField(
                    textInputAction: TextInputAction.next,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    enableInteractiveSelection: false,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    controller: calorieController,
                    validator: (value) {
                      num _v = num.tryParse(value);
                      if (_v==null) {
                        return "Enter Correct Calories";
                      } else if ( _v> 2000) {
                        return "Calories shouldn't exceed 2000";
                      } else {
                        return null;
                      }
                    },
                    decoration: InputDecoration(
                      hintText: "Calories",
                      hintStyle: TextStyle(
                        color: Colors.grey.shade500,
                        fontStyle: FontStyle.normal,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 3.h,
                  ),
                  const Text('Protein (in grams)'),
                  TextFormField(
                    textInputAction: TextInputAction.next,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    enableInteractiveSelection: false,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    controller: protienController,
                    validator: (value) {
                      if (value.isEmpty) {
                        // return "Proteins shouldn't be empty";
                        return null;
                      } else {
                        var _v = num.tryParse(value);
                        if (_v != null) {
                          if ((_v > 1000)) {
                            return 'Enter the Proteins between 0-1000';
                          }
                        } else {
                          return "Enter valid Quantity";
                        }
                        return null;
                      }
                    },
                    decoration: InputDecoration(
                      hintText: "Proteins",
                      hintStyle: TextStyle(
                        color: Colors.grey.shade500,
                        fontStyle: FontStyle.normal,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 3.h,
                  ),
                  const Text('Carbohydrates (in grams)'),
                  TextFormField(
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    textInputAction: TextInputAction.next,
                    enableInteractiveSelection: false,
                    controller: carbController,
                    validator: (value) {
                      if (value.isEmpty) {
                        // return "Carbohydrates shouldn't be empty";
                        return null;
                      } else {
                        var _v = num.tryParse(value);
                        if (_v != null) {
                          if ((_v > 1000)) {
                            return 'Enter the Carbohydrates between 0-1000';
                          }
                        } else {
                          return "Enter valid Quantity";
                        }
                        return null;
                      }
                    },
                    decoration: InputDecoration(
                      hintText: "Carbohydrates",
                      hintStyle: TextStyle(
                        color: Colors.grey.shade500,
                        fontStyle: FontStyle.normal,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 3.h,
                  ),
                  const Text('Fibres (in grams)'),
                  TextFormField(
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    textInputAction: TextInputAction.next,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    enableInteractiveSelection: false,
                    controller: fiberController,
                    validator: (value) {
                      if (value.isEmpty) {
                        // return "Fibers shouldn't be empty";
                        return null;
                      } else {
                        var _v = num.tryParse(value);
                        if (_v != null) {
                          if ((_v > 1000)) {
                            return 'Enter the Fibers between 0-1000';
                          }
                        } else {
                          return "Enter valid Quantity";
                        }
                        return null;
                      }
                    },
                    decoration: InputDecoration(
                      hintText: "Fiber",
                      hintStyle: TextStyle(
                        color: Colors.grey.shade500,
                        fontStyle: FontStyle.normal,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 3.h,
                  ),
                  const Text('Saturated Fat (in grams) '),
                  TextFormField(
                    enableInteractiveSelection: false,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    textInputAction: TextInputAction.done,
                    controller: totalFatController,
                    validator: (value) {
                      if (value.isEmpty) {
                        // return "Saturated shouldn't be empty";
                        return null;
                      } else {
                        var _v = num.tryParse(value);
                        if (_v != null) {
                          if ((_v > 1000)) {
                            return 'Enter the Saturated between 0-1000';
                          }
                        } else {
                          return "Enter valid Quantity";
                        }
                        return null;
                      }
                    },
                    decoration: InputDecoration(
                      hintText: "Saturated Fat",
                      hintStyle: TextStyle(
                        color: Colors.grey.shade500,
                        fontStyle: FontStyle.normal,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 3.h,
                  ),
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        if (formKey.currentState.validate()) {
                          createCustomFood();
                        }
                      },
                      child: Container(
                        height: 5.h,
                        width: 42.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(7),
                          color: const Color(0xffEE6143),
                        ),
                        child: Center(
                          child: Text(
                            'Submit',
                            style: TextStyle(color: Colors.white, fontSize: 17.sp),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 14.h,
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
