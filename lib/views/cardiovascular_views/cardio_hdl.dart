import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:ihl/utils/ScUtil.dart';
import 'package:ihl/utils/SpUtil.dart';
import 'package:ihl/views/cardiovascular_views/cardiovascular_survey.dart';
import 'package:ihl/widgets/offline_widget.dart';
import 'package:ihl/widgets/weight.dart';
import 'package:ihl/constants/routes.dart';
import 'package:ihl/constants/app_texts.dart';
import 'package:ihl/utils/sizeConfig.dart';

class CardioHdl extends StatefulWidget {
  CardioHdl({Key key}) : super(key: key);

  @override
  _CardioHdlState createState() => _CardioHdlState();
}

class _CardioHdlState extends State<CardioHdl> {
  int high_density_lipoprotein = 70;
  bool mannual = true;
  FocusNode mobFocusNode;
  final _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  TextEditingController hdlController = TextEditingController();
  void _initAsync() async {
    await SpUtil.getInstance();
    var cardio_hdl;
    try{
      cardio_hdl = SpUtil.getString('cardio_hdl');
    }
    catch(e){print(e.toString());}
    if(cardio_hdl.toString()!='null'||cardio_hdl.toString()!=''){
      setState(() {
        hdlController.text = cardio_hdl.toString();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _initAsync();
  }

  Widget cholesterolTextField() {
    return StreamBuilder<String>(
      builder: (context, snapshot) {
        return TextFormField(
          controller: hdlController,
          validator: (value) {
            if (value.isEmpty) {
              return 'high density lipoprotein\'s value can\'t be empty!';
            } else if ((double.parse(value) < 5.00) && value.isNotEmpty) {
              return "Please enter correct value";
            } else if ((double.parse(value) > 300.00) && value.isNotEmpty) {
              return "Please enter correct value !";
            }
            return null;
          },
          decoration: InputDecoration(
            contentPadding:
            EdgeInsets.symmetric(vertical: 18.0, horizontal: 15.0),
            suffixText: 'mg/dL',
            labelText: "high density lipoprotein (in mg/dL)",
            counterText: "",
            counterStyle: TextStyle(fontSize: 0),
            fillColor: Colors.white,
            border: new OutlineInputBorder(
                borderRadius: new BorderRadius.circular(15.0),
                borderSide: new BorderSide(color: Colors.blueGrey)),
          ),
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          style: TextStyle(
            fontSize: ScUtil().setSp(16),
          ),
          focusNode: mobFocusNode,
          textInputAction: TextInputAction.done,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ScUtil.init(context, width: 360, height: 640, allowFontScaling: true);
    Widget _customButton() {
      return Container(
        height: 60,
        child: GestureDetector(
          onTap: () {
            if (mannual == false) {
              SpUtil.putString('cardio_hdl', high_density_lipoprotein.toString());
              // Navigator.of(context).pushNamed(Routes.Aff);
              // Navigator.of(context).pushNamed(Routes.Spic);
              currentIndexOfCardio.value=7;
            } else {
              if (_formKey.currentState.validate()) {
                if (this.mounted) {
                  // setState(() {
                  SpUtil.putString('cardio_hdl', hdlController.text);
                  // Navigator.of(context).pushNamed(Routes.Aff);
                  // Navigator.of(context).pushNamed(Routes.Spic);
                  currentIndexOfCardio.value=7;
                  // });
                }
              } else {
                if (this.mounted) {
                  setState(() {
                    _autoValidate = true;
                  });
                }
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
                  child: Text(
                    AppTexts.continuee,
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
      );
    }

    return Form(
      key: _formKey,
      autovalidateMode:AutovalidateMode.onUserInteraction,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: 6 * SizeConfig.heightMultiplier,
            ),
            Text(
              'Enter Your High-density lipoprotein\'s value' ,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Color.fromRGBO(109, 110, 113, 1),
                  fontFamily: 'Poppins',
                  fontSize: ScUtil().setSp(26),
                  letterSpacing: 0,
                  fontWeight: FontWeight.bold,
                  height: 1.33),
            ),
            SizedBox(
              height: 1 * SizeConfig.heightMultiplier,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 50.0, right: 50.0),
              child: Text(
                AppTexts.sub8,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Color.fromRGBO(109, 110, 113, 1),
                    fontFamily: 'Poppins',
                    fontSize: ScUtil().setSp(15),
                    letterSpacing: 0.2,
                    fontWeight: FontWeight.normal,
                    height: 1),
              ),
            ),
            // mannual == false
            //     ? Container(
            //   padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
            //   child: WeightSlider(
            //     weight: cholesterol,
            //     minWeight: 40,
            //     maxWeight: 250,
            //     onChange: (val) {
            //       if (this.mounted) {
            //         setState(() => this.cholesterol = val);
            //       }
            //     },
            //   ),
            // )
            //     :
            Padding(
              padding: const EdgeInsets.only(
                  top: 40, left: 30.0, right: 30.0),
              child: Container(
                child: cholesterolTextField(),
              ),
            ),
            // TextButton(
            //     onPressed: () {
            //       if (this.mounted) {
            //         setState(() {
            //           mannual = !mannual;
            //         });
            //       }
            //     },
            //     child: mannual == false
            //         ? Text('Not Seeing your weight? Enter Manually',
            //         style: TextStyle(
            //           color: Color(0xFF19a9e5),
            //           fontSize: ScUtil().setSp(14),))
            //         : Text('Use Slider instead',
            //         style: TextStyle(
            //           color: Color(0xFF19a9e5),
            //           fontSize: ScUtil().setSp(14),))),
            SizedBox(
              height: 6 * SizeConfig.heightMultiplier,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 50.0, right: 50.0),
              child: Center(
                child: _customButton(),
              ),
            ),
            SizedBox(
              height: 1 * SizeConfig.heightMultiplier,
            ),
          ],
        ),
      ),
    );
  }
}
