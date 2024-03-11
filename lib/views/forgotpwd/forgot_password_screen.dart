import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../models/data_helper.dart';
import '../../new_design/data/providers/network/networks.dart';
import '../../repositories/repositories.dart';
import '../../utils/SpUtil.dart';
import '../../utils/app_colors.dart';
import '../../utils/screenutil.dart';
import '../../utils/sizeConfig.dart';
import 'forgot_pwd_enter.dart';
import '../../widgets/signin_email.dart';
import '../../widgets/sigin_pwd.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import '../../constants/api.dart';

final String iHLUrl = API.iHLUrl;
final String ihlToken = API.ihlToken;

class ForgotPasswordPage extends StatelessWidget {
  static const String id = '/signin_pwd';

  final Apirepository apiRepository;
  const ForgotPasswordPage({Key key, @required this.apiRepository})
      : assert(apiRepository != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: ForgotPassword(),
    );
  }
}

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key key}) : super(key: key);

  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final http.Client _client = http.Client(); //3gb
  String apiToken;
  bool userExistR = true;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  bool emailchar = false;
  bool mobilechar = false;
  bool isChecking = false;
  final TextEditingController _emailController = TextEditingController();
  bool forgotPasswordSuccess = false;
  bool isLoading = false;
  bool mobileSuccess = false;

  Future<bool> userExist() async {
    final http.Response response = await _client.get(
      Uri.parse('$iHLUrl/login/kioskLogin?id=2936'),
      headers: {'ApiToken': ihlToken},
    );
    if (response.statusCode == 200) {
      Signup reponseToken = Signup.fromJson(json.decode(response.body));
      apiToken = reponseToken.apiToken;
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('auth_token', reponseToken.apiToken);
      final http.Response userExits = await _client.get(
        Uri.parse(
            '$iHLUrl/login/emailormobileused?email=${_emailController.text}&mobile=&aadhaar='),
        headers: {'ApiToken': reponseToken.apiToken},
      );
      if (userExits.statusCode == 200) {
        String userExistResponse = userExits.body.replaceAll(RegExp(r'[^\w\s]+'), '');
        if (userExistResponse == "You never registered with this Email ID") {
          if (mounted) {
            setState(() {
              userExistR = false;
              isChecking = false;
            });
          }
          return userExistR;
        } else {
          if (mounted) {
            setState(() {
              userExistR = true;
            });
          }

          String userExistResponse = "User already exist";
          return userExistR;
        }
      } else {
        throw Exception('Authorization Failed');
      }
    }
    return userExistR;
  }

  void _initAsync() async {
    await SpUtil.getInstance();
  }

  @override
  void initState() {
    super.initState();
    _initAsync();
    _emailController.addListener(() {
      if (mounted) {
        setState(() {
          emailchar = _emailController.text.contains(
              RegExp(
                  "^[a-zA-Z0-9.!#\$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*\$"),
              0);
          mobilechar = _emailController.text.contains(RegExp(r'(^(?:[+0]9)?[0-9]{10,12}$)'));
        });
      }
    });
  }

  Future<bool> forgotPassword(BuildContext context) async {
    // final forgotPasswordAPI = await _client.get(
    //   Uri.parse(iHLUrl + '/login/passreset?email=' + _emailController.text),
    //   headers: {
    //     'ApiToken': apiToken,
    //   },
    // );

    final Response forgotPasswordAPI = await dio.get('$iHLUrl/login/passreset',
        options: Options(
          headers: {'ApiToken': apiToken},
        ),
        queryParameters: {'email': _emailController.text});
    if (forgotPasswordAPI.statusCode == 200) {
      var forgotPasswordAPIResponse = forgotPasswordAPI.data.replaceAll(RegExp(r'[^\w\s]+'), '');
      if (forgotPasswordAPIResponse == "success") {
        forgotPasswordSuccess = true;
        SnackBar snackBar = const SnackBar(
          content: Text('Temporary Password has been sent to Your Registered E-mail ID'),
          backgroundColor: Colors.green,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        Fluttertoast.showToast(
            msg: "Temporary Password has been sent to Your Registered E-mail ID",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.grey,
            textColor: Colors.white,
            fontSize: 16.0);
        Navigator.push(
            context, MaterialPageRoute(builder: (BuildContext context) => ForgotPwdEnter()));
        isLoading = true;
        return forgotPasswordSuccess;
      } else {
        forgotPasswordSuccess = false;
        throw Exception('Generating new password failed');
      }
    }
    return forgotPasswordSuccess;
  }

  Future<bool> authorize() async {
    final http.Response response = await _client.get(
      Uri.parse('$iHLUrl/login/kioskLogin?id=2936'),
      headers: {'ApiToken': ihlToken},
    );
    if (response.statusCode == 200) {
      Signup student = Signup.fromJson(json.decode(response.body));
      apiToken = student.apiToken;

      // SharedPreferences prefs = await SharedPreferences.getInstance();
      String email = SpUtil.getString('email');
      print(email);
      if (!emailchar) {
        forgotPasswordMobile(mobile: _emailController.text);
      } else {
        forgotPassword(context);
      }
    } else {
      print("Authorization failed");
    }
  }

  // Forgot Password Mobile number flow API
  Future<bool> forgotPasswordMobile({String mobile}) async {
    final http.Response forgotPasswordAPI = await _client.get(
      Uri.parse('$iHLUrl/login/mobile_pass_reset?mobile=$mobile'),
      headers: {
        'ApiToken': apiToken,
      },
    );
    if (forgotPasswordAPI.statusCode == 200) {
      String forgotPasswordAPIResponse = forgotPasswordAPI.body.replaceAll(RegExp(r'[^\w\s]+'), '');
      if (forgotPasswordAPIResponse == "sent") {
        mobileSuccess = true;
        Navigator.push(
            context, MaterialPageRoute(builder: (BuildContext context) => ForgotPwdEnter()));
        Fluttertoast.showToast(
            msg: "Temporary Password has been sent to Your Registered E-mail ID",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.grey,
            textColor: Colors.white,
            fontSize: 16.0);
        return mobileSuccess;
      } else if (forgotPasswordAPIResponse == "fail") {
        mobileSuccess = false;
        return mobileSuccess;
      }
    } else {}
    return mobileSuccess;
  }

  Widget emailTextField() {
    return StreamBuilder<String>(
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        return TextFormField(
          keyboardType: TextInputType.visiblePassword,
          controller: _emailController,
          autocorrect: true,
          validator: (String value) {
            if (value.isEmpty) {
              return 'Please Enter Your Credentials';
            } else if (!(emailchar) && (!(mobilechar)) && value.isNotEmpty) {
              return "Invalid Credentials";
            }
            return null;
          },
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 18),
            prefixIcon: const Padding(
              padding: EdgeInsetsDirectional.only(end: 8.0),
              child: Icon(Icons.person),
            ),
            labelText: "Registered Email or Mobile",
            fillColor: Colors.white24,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.0),
                borderSide: const BorderSide(color: Colors.blueGrey)),
          ),
          maxLines: 1,
          style: const TextStyle(fontSize: 16.0),
          textInputAction: TextInputAction.done,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ScUtil.init(context, width: 360, height: 640, allowFontScaling: true);
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xffF4F6FA),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          centerTitle: true,
          title: Padding(
            padding: const EdgeInsets.only(top: 3.0),
            child: Text(
              'Forgot password?',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: const Color(0xff6D6E71),
                fontSize: ScUtil().setSp(18),
              ),
            ),
          ),
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            ),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (BuildContext context) => const LoginPasswordPage())),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                FocusScopeNode currentFocus = FocusScope.of(context);
                if (!currentFocus.hasPrimaryFocus) {
                  currentFocus.unfocus();
                }
                if (mounted) {
                  setState(() {
                    isChecking = true;
                  });
                }
                if (_formKey.currentState.validate()) {
                  userExist();
                  Future.delayed(const Duration(seconds: 6), () {
                    if (userExistR == true) {
                      authorize();
                      if (mounted) {
                        setState(() {
                          print(_emailController.text);
                          SpUtil.putString('email', _emailController.text);
                          String a = SpUtil.getString('email');
                          print(a);
                          isChecking = false;
                        });
                      }
                    }
                  });
                } else {
                  if (mounted) {
                    setState(() {
                      isChecking = false;
                      _autoValidate = true;
                    });
                  }
                }
              },
              style: TextButton.styleFrom(
                textStyle: const TextStyle(
                  color: Color(0xFF19a9e5),
                ),
                shape: const CircleBorder(side: BorderSide(color: Colors.transparent)),
              ),
              child: Text("Send",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: ScUtil().setSp(16),
                  )),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 35.0,
                ),
                const SizedBox(
                  height: 20.0,
                ),
                Center(
                    child: Text(
                  'Get your new password',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: ScUtil().setSp(24),
                      color: const Color(0xff6D6E71)),
                )),
                const SizedBox(
                  height: 10.0,
                ),
                Center(
                    child: Text(
                  'through Email',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: ScUtil().setSp(24),
                      color: const Color(0xff6D6E71)),
                )),
                const SizedBox(
                  height: 10.0,
                ),
                Center(
                    child: Text(
                  'or Mobile',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: ScUtil().setSp(24),
                      color: const Color(0xff6D6E71)),
                )),
                const SizedBox(
                  height: 50.0,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                  child: Container(
                    child: Column(
                      children: [
                        emailTextField(),
                        userExistR == false
                            ? Text(
                                'Email/Mobile No. Not Registered',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: ScUtil().setSp(12),
                                ),
                              )
                            : SizedBox(height: 1 * SizeConfig.heightMultiplier)
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'I know my password',
                      style: TextStyle(
                        fontSize: ScUtil().setSp(18),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(right: 0.0),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) => const LoginEmailScreen()));
                      },
                      style: TextButton.styleFrom(
                        textStyle: const TextStyle(
                          color: AppColors.primaryColor,
                        ),
                        shape: const CircleBorder(side: BorderSide(color: Colors.transparent)),
                      ),
                      child: Text(
                        "Login here",
                        style: TextStyle(
                          fontSize: ScUtil().setSp(18),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 30.0,
                ),
                isChecking == true
                    ? Builder(
                        builder: (BuildContext context) => Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            height: ScUtil().setSp(60),
                            width: ScUtil().setSp(150),
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16.0),
                                  ),
                                ),
                                onPressed: () {},
                                child: const CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                )),
                          ),
                        ),
                      )
                    : Builder(
                        builder: (BuildContext context) => Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            height: ScUtil().setSp(60),
                            width: ScUtil().setSp(300),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.0),
                                ),
                              ),
                              onPressed: isChecking == true
                                  ? () {}
                                  : () async {
                                      FocusScopeNode currentFocus = FocusScope.of(context);
                                      if (!currentFocus.hasPrimaryFocus) {
                                        currentFocus.unfocus();
                                      }
                                      if (mounted) {
                                        setState(() {
                                          isChecking = true;
                                        });
                                      }
                                      if (_formKey.currentState.validate()) {
                                        userExist();
                                        Future.delayed(const Duration(seconds: 6), () {
                                          if (userExistR == true) {
                                            authorize();
                                            if (mounted) {
                                              setState(() {
                                                print(_emailController.text);
                                                SpUtil.putString('email', _emailController.text);
                                                String a = SpUtil.getString('email');
                                                print(a);
                                                // isChecking = false;
                                              });
                                            }
                                          }
                                        });
                                      } else {
                                        if (mounted) {
                                          setState(() {
                                            isChecking = false;
                                            _autoValidate = true;
                                          });
                                        }
                                      }
                                    },
                              child: isChecking == true
                                  ? const CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    )
                                  : Text("Send my new password",
                                      style: TextStyle(
                                        fontSize: ScUtil().setSp(18),
                                      )),
                            ),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
