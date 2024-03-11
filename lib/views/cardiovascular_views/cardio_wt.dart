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

class CardioWt extends StatefulWidget {
  CardioWt({Key key,this.weight}) : super(key: key);
  final weight;

  @override
  _CardioWtState createState() => _CardioWtState();
}

class _CardioWtState extends State<CardioWt> {
  int weight = 70;
  bool loading =true;
  bool mannual = false;
  FocusNode mobFocusNode;
  final _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  TextEditingController weightController = TextEditingController();
  void _initAsync() async {
    await SpUtil.getInstance();
    var cardio_wt;
    try{
      cardio_wt = SpUtil.getString('cardio_weight');
      if(cardio_wt.toString()!='null'&&cardio_wt.toString()!=''){
        setState(() {
          weight = int.tryParse(cardio_wt);
          print(weight);
          loading=false;
        });
        // height = (_height*100).toInt();
      }
    }
    catch(e){
      print(e.toString());
    }

    if(cardio_wt.toString()=='null'||cardio_wt==''||weight.toString()=='null'||weight.toString()==''){
      ///put the value from userDretail here
      if(widget.weight.toString()!='null'&& widget.weight!=''){
        setState(() {
          weight = int.tryParse(widget.weight);
          print(weight);
          loading=false;
          // _height =double.tryParse( widget.height);
          // height = (_height*100).toInt();
        });
      }
    }
  }


  @override
  void initState() {
    super.initState();
    _initAsync();
  }

  Widget weightTextField() {
    return StreamBuilder<String>(
      builder: (context, snapshot) {
        return TextFormField(
          controller: weightController,
          validator: (value) {
            if (value.isEmpty) {
              return 'Weight can\'t be empty!';
            } else if ((double.parse(value) < 5.00) && value.isNotEmpty) {
              return "Min. Weight is 5 Kgs";
            } else if ((double.parse(value) > 200.00) && value.isNotEmpty) {
              return "Max. Weight cannot surpass 200 Kg";
            }
            return null;
          },
          decoration: InputDecoration(
            contentPadding:
            EdgeInsets.symmetric(vertical: 18.0, horizontal: 15.0),
            suffixText: 'KGs',
            labelText: "Weight (in KG)",
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
              SpUtil.putString('cardio_weight', weight.toString());
              // Navigator.of(context).pushNamed(Routes.Aff);
              // Navigator.of(context).pushNamed(Routes.Spic);
              currentIndexOfCardio.value=4;
            } else {
              if (_formKey.currentState.validate()) {
                if (this.mounted) {
                  // setState(() {
                    SpUtil.putString('cardio_weight', weightController.text);
                    // Navigator.of(context).pushNamed(Routes.Aff);
                    // Navigator.of(context).pushNamed(Routes.Spic);
                    currentIndexOfCardio.value=4;
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
              AppTexts.weight,
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
            mannual == false
                ? Container(
              padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
              child: Visibility(
                visible: loading==false,
                replacement: CircularProgressIndicator(),
                child: WeightSlider(
                  weight: weight??70,
                  minWeight: 40,
                  maxWeight: 250,
                  onChange: (val) {
                    if (this.mounted) {
                      setState(() => this.weight = val);
                    }
                  },
                ),
              ),
            )
                : Padding(
              padding: const EdgeInsets.only(
                  top: 40, left: 30.0, right: 30.0),
              child: Container(
                child: weightTextField(),
              ),
            ),
            TextButton(
                onPressed: () {
                  if (this.mounted) {
                    setState(() {
                      mannual = !mannual;
                    });
                  }
                },
                child: mannual == false
                    ? Text('Not Seeing your weight? Enter Manually',
                    style: TextStyle(
                      color: Color(0xFF19a9e5),
                      fontSize: ScUtil().setSp(14),))
                    : Text('Use Slider instead',
                    style: TextStyle(
                      color: Color(0xFF19a9e5),
                      fontSize: ScUtil().setSp(14),))),
            SizedBox(
              height: 2 * SizeConfig.heightMultiplier,
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
