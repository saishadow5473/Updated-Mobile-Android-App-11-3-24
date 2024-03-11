import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:ihl/utils/ScUtil.dart';
import 'package:ihl/utils/SpUtil.dart';
import 'package:ihl/views/cardiovascular_views/cardiovascular_survey.dart';
import 'package:ihl/widgets/height.dart';
import 'package:ihl/constants/routes.dart';
import 'package:ihl/constants/app_texts.dart';
import 'package:ihl/utils/sizeConfig.dart';
import 'package:ihl/widgets/offline_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CardioHt extends StatefulWidget {
  String height;
  CardioHt({Key key, @required this.height}) : super(key: key);

  @override
  _CardioHtState createState() => _CardioHtState();
}

class _CardioHtState extends State<CardioHt> {
  int height = 170;
  double _height = 1.70;
  bool isMaleSelected = true;
  TextEditingController heightController = TextEditingController();

  void _initAsync() async {
    await SpUtil.getInstance();
    var cardio_ht;
    try{
      cardio_ht = SpUtil.getString('cardio_height');
      if(cardio_ht.toString()!='null'&&cardio_ht.toString()!=''){
        _height = double.tryParse(cardio_ht);
        height = (_height*100).toInt();
      }
    }
    catch(e){
      print(e.toString());
    }

    if(cardio_ht.toString()=='null'||cardio_ht==''){
      ///put the value from userDretail here
      if(widget.height.toString()!='null'&& widget.height!=''){
        setState(() {
          _height =double.tryParse( widget.height);
          height = (_height*100).toInt();
        });
      }
    }

  }
  var cGen = 'm';
  getGenderDetail() async{
    SharedPreferences pref = await SharedPreferences.getInstance();
     cGen = pref.getString('cardio_gender');
    setState(() {
      // widget.gender= cGen;
      if(cGen=="female"|| cGen=="f"){
        cGen = "f";
      }
      else if(cGen == "male"||cGen == "m"){
        cGen = "m";
      }
      print(cGen);
    });
  }

  @override
  void initState() {
    getGenderDetail();
    super.initState();
    _initAsync();
  }

  @override
  Widget build(BuildContext context) {
    ScUtil.init(context, width: 360, height: 640, allowFontScaling: true);
    Widget _customButton() {
      return Container(
        height: 60,
        child: GestureDetector(
          onTap: () {
            SpUtil.putString('cardio_height', _height.toString());
            currentIndexOfCardio.value = 3;
            // Navigator.of(context).pushNamed(Routes.Sweight);
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
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[

          // SizedBox(
          //   height: 1 * SizeConfig.heightMultiplier,
          // ),
          Text(
            AppTexts.height,
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
              AppTexts.sub7,
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
          SizedBox(
            height: 1.5 * SizeConfig.heightMultiplier,
          ),
          Container(
            padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
            height: 400,
            child: HeightSlider(
              height: this.height,
              numberLineColor: Colors.black,
              currentHeightTextColor: Colors.black,
              sliderCircleColor: Colors.blue,
              onChange: (val) {
                if (this.mounted) {
                  setState(() {
                    this.height = val;
                    this._height = val / 100;
                  });
                }
              },
              personImagePath: cGen == 'm'
                  ? 'assets/svgs/boy.svg'
                  : cGen == 'f'
                  ? 'assets/svgs/lady.svg'
                  : 'assets/svgs/others.svg',
            ),
          ),
          SizedBox(
            height: 1.5 * SizeConfig.heightMultiplier,
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
    );
  }
}
